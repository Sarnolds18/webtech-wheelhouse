# Deployment

**Production: http://3.132.219.198** (plain HTTP on port 80; `/up` answers `200`).

The instructor allowed a cloud provider other than DigitalOcean as long as every requirement can be
shown, so the server is an **AWS EC2** instance instead of a droplet:

| | |
|---|---|
| Region | `us-east-2` (US East, Ohio) |
| Size | `t3.small`: 2 vCPU, 2 GB of memory, x86-64; 20 GB gp3 disk; 2 GB swap file |
| System | Ubuntu Server 24.04 LTS, Docker Engine 29.9.3 |
| Address | Elastic IP `3.132.219.198`, so it does not change when the instance stops or reboots |
| Firewall (security group) | Inbound 22 only from the administrator's IP, inbound 80 from anywhere; nothing else (no 443, no 5432) |
| Deployed version | `9cdea6ca19bdb2ae5514123a193d87915d097b1d`, the last deploy in [Deploys](#deploys-and-the-rollback) |

## Infrastructure

Kamal 2 deploys over SSH as `ubuntu`. The server needs Docker installed and that user must be able
to use it. The laptop needs Docker with Buildx, Ruby and the gems from `bundle install`.

**The image is built on a remote builder: the server itself.** Kamal sends a clean Git checkout of the
commit to Docker Buildx on the server over SSH (`builder.remote` in `config/deploy.yml`), which builds
it for the server's `amd64` CPU and pushes it to Docker Hub; the app container is then pulled from
Docker Hub. A local build was tried first, but the laptop's upload link (about 0.3 MB/s) made Docker
Hub time out on the largest layer. The server has a 2 GB swap file so a build fits next to the running
app. Docker's SSH client reads the key from `~/.ssh/config` on the laptop:

```
Host <server IP>
  User ubuntu
  IdentityFile ~/.ssh/wheelhouse-lab13.pem
  IdentitiesOnly yes
```

| Container | Runs | Listening ports |
|---|---|---|
| `kamal-proxy` | Routes HTTP requests to Rails | Host ports 80 and 443; the lab uses HTTP on 80 |
| `webtech_wheelhouse-web-<SHA>` | Rails through Thruster, with Solid Queue in Puma | Thruster on 80 inside the Kamal network; Puma on 3000 inside the container |
| `webtech_wheelhouse-db` | PostgreSQL 18, as a Kamal accessory | 5432 inside the Kamal network; no host port published |
| `buildx_buildkit_kamal-remote-ssh---ubuntu-3-132-219-1980` | BuildKit, the remote builder Kamal created with `docker buildx create` to build the image | None |

Every container was started by Kamal (`kamal setup`, `kamal deploy`, `kamal rollback`,
`kamal accessory reboot`); no command was run on the server to start one.

The security group allows inbound HTTP on 80 and SSH on 22 from the administrator's IP only, and
not PostgreSQL on 5432. From the laptop, a TCP connection to `3.132.219.198:5432` fails.

**SSH accepts only a key.** `keys_only` in `config/deploy.yml` only chooses the client's key; the
server itself refuses passwords. Its effective configuration (`sudo sshd -T`) has
`passwordauthentication no` and `kbdinteractiveauthentication no`, and a sign-in that offers only a
password is refused:

```
$ ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password,keyboard-interactive ubuntu@3.132.219.198
ubuntu@3.132.219.198: Permission denied (publickey).
```

### Persistent state

- **Rows, jobs, cache and cable messages:** all four production databases live in the
  `webtech_wheelhouse_postgres` volume, mounted at `/var/lib/postgresql`. PostgreSQL 18 keeps
  its data below that mount. All four use `DB_HOST=webtech_wheelhouse-db` and the same database
  account. A normal application deploy does not replace the accessory or its volume.
- **Photos:** originals and variants live in `webtech_wheelhouse_storage`, mounted at
  `/rails/storage`. Each new application container reuses it.
- **Emails:** `deliver_later` puts a delivery job in the queue database; Solid Queue, running inside
  Puma, sends it to Brevo's SMTP relay. Delivered email lives in the recipient's mailbox. A deploy
  keeps the queue database, so a job enqueued just before it runs in the new container.

### Seed data and production passwords

The image's entrypoint (`bin/docker-entrypoint`) runs `bin/rails db:prepare` before Rails starts. On
the first boot, with an empty accessory, it creates the four databases, loads their schemas and
**loads `db/seeds.rb` once**, because the primary database was just created. Later boots and deploys
only apply pending migrations; they never seed again. Nothing is run by hand to load the seed. The
seed sends no email: the welcome email is sent only by the sign-up page.

The seed's passwords are published in the README, so right after the first deploy every account gets
a new random password:

```bash
bin/kamal app exec "bin/rails wheelhouse:rotate_passwords"
```

The task prints each address, role and new password **once, in the laptop's terminal**, and closes
every session. Those passwords go to a password manager and to the private Canvas comment, never to
the repository. To stop the published passwords from coming back, `db/seeds.rb` refuses to run in
production once any account exists.

**What happened in production.** The seed was loaded by that entrypoint, in the first container
(`efac78f`) started by `kamal setup`, on 2026-11-10 at 14:16:38 UTC. Its log line:

```
Seeded: 12 customers, 10 bike models, 13 bikes, 5 staff, 6 accounts, 21 services, 16 repairs, 24 repair services, 5 invoices, 31 intake photos (7 files), 14 diagnoses.
```

The passwords were rotated a minute later, at 14:17:39 UTC (`kamal audit` below). Then the six
seed passwords were each tried on the production sign-in form, and every one was refused.

## Local variables and secrets

Export these in the same Bash session that will run Kamal. Replace the non-secret examples:

```bash
export WHEELHOUSE_HOST="YOUR_EC2_PUBLIC_IP"
export KAMAL_REGISTRY_USERNAME="YOUR_DOCKER_HUB_USERNAME"
export WHEELHOUSE_SSH_KEY="$HOME/.ssh/wheelhouse-lab13.pem"
export RAILS_MASTER_KEY="$(cat config/master.key)"

read -r -s -p "Docker Hub access token: " KAMAL_REGISTRY_PASSWORD
echo
export KAMAL_REGISTRY_PASSWORD

read -r -s -p "PostgreSQL password: " WEBTECH_WHEELHOUSE_DATABASE_PASSWORD
echo
export WEBTECH_WHEELHOUSE_DATABASE_PASSWORD
```

In this deployment the five values other than the master key (`WHEELHOUSE_HOST`,
`KAMAL_REGISTRY_USERNAME`, `WHEELHOUSE_SSH_KEY` and the two secrets) are kept on the laptop in `~/.wheelhouse-lab13.env`
(mode 600, outside the repository) and loaded with `set -a; . ~/.wheelhouse-lab13.env; set +a`
before running Kamal.

The registry token needs pull and push permission for the account's `webtech_wheelhouse` image.
Keep the database password in a password manager: changing an exported variable does not change
the password of an already initialized PostgreSQL cluster.

| Secret | Where its value is kept | How it reaches its destination |
|---|---|---|
| `KAMAL_REGISTRY_PASSWORD` | Password manager; exported locally | `.kamal/secrets` reads it; Kamal logs in to Docker Hub on the laptop and server |
| `RAILS_MASTER_KEY` | Ignored local `config/master.key`; exported locally | Kamal injects it into the Rails container at runtime |
| `WEBTECH_WHEELHOUSE_DATABASE_PASSWORD` | Password manager; exported locally | Injected into Rails under this name and into PostgreSQL as `POSTGRES_PASSWORD` |
| Brevo SMTP login and SMTP key | Encrypted `config/credentials.yml.enc`, under `smtp.user_name` and `smtp.password` | Rails decrypts them in the container with `RAILS_MASTER_KEY`; no environment variable of their own |
| API token (`api_token`) and `secret_key_base` | Encrypted `config/credentials.yml.enc` | Decrypted in the container with `RAILS_MASTER_KEY` |
| Passwords of the production accounts | Password manager and the private Canvas comment | Set in the database by `wheelhouse:rotate_passwords`; only their bcrypt digests are stored |
| SSH private key | `~/.ssh/wheelhouse-lab13.pem` on the laptop, mode 600 | Kamal and Docker's SSH client read it to reach the server; it is never copied anywhere |

`.kamal/secrets` contains references only. No secret is passed as a Docker build argument.
The image excludes local key files and uses `SECRET_KEY_BASE_DUMMY` only to compile assets.

## HTTP transport

The proxy has `ssl: false`; Rails production has both `assume_ssl` and `force_ssl` disabled.
Requests and authentication cookies can use HTTP on the public IP. The reasons, transport risks,
browser warnings and GitHub Pages mixed-content limitation are documented in
[decisions.md, section 7](decisions.md#7-plain-http-on-the-production-ip-lab-13).

## Email

Production sends email through **Brevo** (free plan) at `smtp-relay.brevo.com`, **port 587** with
STARTTLS. The sender is `Wheelhouse <sarnolds@miuandes.cl>`, an address Brevo has verified. Links in
emails use `APP_HOST` (the server's IP) over `http://`, with no port. A failed delivery raises, so it
stays as a failed job in the queue database instead of vanishing. Development still writes emails
to `tmp/mails/` and sends nothing.

To set the SMTP login and key, run `bin/rails credentials:edit` and add:

```yaml
smtp:
  user_name: <Brevo SMTP login>
  password: <Brevo SMTP key>
```

**How the jobs and the email were checked**, on 2026-11-10: a new account was made on the sign-up page
with a real Gmail address at 14:33:24 UTC, and a new password was asked for it on the
forgotten-password page at 14:33:25 UTC. The log shows each `ActionMailer::MailDeliveryJob` performed
by Solid Queue (in Puma) two seconds later, at 14:33:26 and 14:33:27, and both emails were in the
inbox within the minute. The link of the password email opened
`http://3.132.219.198/passwords/<token>/edit`; the new password was chosen there and the account
signed in with it. Then the queue database was read from the console
(`bin/kamal app exec --reuse "bin/rails runner ..."`):

```
{"ActiveStorage::AnalyzeJob" => 8, "ActionMailer::MailDeliveryJob" => 2}
finished=10 ready=0 scheduled=0 claimed=0 failed=0
```

No job was waiting, claimed or failed.

## The API in production

Every route of `/api/v1` answers at `http://3.132.219.198/api/v1` with the same statuses as locally
(checked with `curl`): the services list and one service `200`, an unknown service `404`, repairs
without a token or with a wrong one `401`, with the token `200` (also filtered by `state`), a bad
`state` `400`, an unknown repair `404`, a new service `201` (missing body `400`, invalid `422`),
an unknown route `404` as JSON.

The Lab 10 page reads it **from the origin `http://localhost:8000`** (scheme `http`, host
`localhost`, port `8000`): a local copy of the page served with `python3 -m http.server 8000`, its
`API_URL` set to `http://3.132.219.198/api/v1` (not committed in `webtech-lab-01`). It showed the
price list and the service asked by id. The CORS headers can be checked with:

```bash
curl -s -D - -o /dev/null -H "Origin: http://localhost:8000" http://3.132.219.198/api/v1/services
```

```
HTTP/1.1 200 OK
Access-Control-Allow-Methods: GET
Access-Control-Allow-Origin: http://localhost:8000
Access-Control-Max-Age: 7200
Vary: Origin
```

The page published on GitHub Pages (`https://`) cannot read it; see
[decisions.md, section 7](decisions.md#7-plain-http-on-the-production-ip-lab-13).

## Persistence checks

Repair #17 was taken in on the production site with two intake photos, then edited (state
*diagnosed*, a diagnosis). It was still there, with both photos shown on its page and both files in
`webtech_wheelhouse_storage`, after each of:

1. `kamal deploy` of `9cdea6c` (14:39 UTC): `repair 17: state=diagnosed photos=2 files_on_disk=2`
2. `kamal accessory reboot db` (14:40 UTC): the PostgreSQL container was removed and started again on
   the same volume
3. a reboot of the server (`sudo reboot`; booted again at 14:41 UTC): Docker started all the
   containers again by their `unless-stopped` restart policy, with no command run by hand

## Deploys and the rollback

| When (UTC) | Command | Commit | What it is |
|---|---|---|---|
| 2026-11-10 14:16 | `bin/kamal setup` | `efac78fe91ec70767dd94e5f1f14961d61ea0ecd` | First deploy: accessory, proxy and app; first boot loaded the seed |
| 2026-11-10 14:39 | `bin/kamal deploy` | `9cdea6ca19bdb2ae5514123a193d87915d097b1d` | README with the production URL and deploy instructions |
| 2026-11-10 14:44 | `bin/kamal rollback efac78fe91ec70767dd94e5f1f14961d61ea0ecd` | `efac78f` | **Rollback**: replaced `9cdea6c`, put `efac78f` back; `bin/kamal app version` answered `efac78fe…` and `/up` `200` |
| 2026-11-10 14:46 | `bin/kamal deploy` | `9cdea6ca19bdb2ae5514123a193d87915d097b1d` | The latest version deployed again; `bin/kamal app version` answered `9cdea6ca…` |

The version answering at the IP is `9cdea6ca19bdb2ae5514123a193d87915d097b1d`, pushed to GitHub. The
commits after it change only documentation.

Two earlier attempts of `kamal setup` stopped while building, before anything was started on the
server (the push from the laptop timed out, and then Kamal built locally again until `local: false`
was set); no container or volume was left on the server.

## Evidence

Taken after the last deploy, on 2026-11-10 at about 14:48 UTC, pasted as printed. No value of a
secret appears in them (Kamal prints `[REDACTED]` for the registry login).

### `bin/kamal app details`

```
  INFO [36b4e59b] Running docker ps --filter label=service=webtech_wheelhouse --filter label=destination= --filter label=role=web on 3.132.219.198
  INFO [36b4e59b] Finished in 2.467 seconds with exit status 0 (successful).
App Host: 3.132.219.198
CONTAINER ID   IMAGE                                                                  COMMAND                  CREATED              STATUS              PORTS     NAMES
53dc51e9204b   sarnolds/webtech_wheelhouse:9cdea6ca19bdb2ae5514123a193d87915d097b1d   "/rails/bin/docker-e…"   About a minute ago   Up About a minute   80/tcp    webtech_wheelhouse-web-9cdea6ca19bdb2ae5514123a193d87915d097b1d
```

### `bin/kamal accessory details db`

`5432/tcp` is only the port inside the Kamal network: a published port would read
`0.0.0.0:5432->5432/tcp`.

```
  INFO [67269761] Running docker ps --filter label=service=webtech_wheelhouse-db on 3.132.219.198
  INFO [67269761] Finished in 2.033 seconds with exit status 0 (successful).
Accessory db Host: 3.132.219.198
CONTAINER ID   IMAGE         COMMAND                  CREATED         STATUS         PORTS      NAMES
201d8bf37026   postgres:18   "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes   5432/tcp   webtech_wheelhouse-db
```

### `bin/kamal audit`

```
  INFO [07cd3378] Running /usr/bin/env tail -n 50 .kamal/webtech_wheelhouse-audit.log on 3.132.219.198
  INFO [07cd3378] Finished in 2.044 seconds with exit status 0 (successful).
App Host: 3.132.219.198
[2026-11-10T14:15:52Z] [sarnolds@miuandes.cl] Pulled image with version efac78fe91ec70767dd94e5f1f14961d61ea0ecd
[2026-11-10T14:16:13Z] [sarnolds@miuandes.cl] Booted db accessory
[2026-11-10T14:16:27Z] [sarnolds@miuandes.cl] [web] Booted app version efac78fe91ec70767dd94e5f1f14961d61ea0ecd
[2026-11-10T14:16:41Z] [sarnolds@miuandes.cl] Tagging sarnolds/webtech_wheelhouse:efac78fe91ec70767dd94e5f1f14961d61ea0ecd as the latest image
[2026-11-10T14:16:42Z] [sarnolds@miuandes.cl] Pruned containers
[2026-11-10T14:16:43Z] [sarnolds@miuandes.cl] Pruned images
[2026-11-10T14:17:39Z] [sarnolds@miuandes.cl] Executed cmd 'bin/rails wheelhouse:rotate_passwords' on app version latest
[2026-11-10T14:19:54Z] [sarnolds@miuandes.cl] [web] Executed cmd 'bin/rails runner "\nActiveRecord::Base.configurations.configs_for(env_name: %q(production)).each { |c| ActiveRecord::Base.establish_connection(c); n = ActiveRecord::Base.connection.tables.size; puts %Q(\#{c.name}: \#{c.database} tables=\#{n}) }\nActiveRecord::Base.establish_connection(:primary)\nmc = ActiveRecord::Base.connection_pool.migration_context\nputs %Q(migrations=\#{mc.migrations.size} pending=\#{mc.needs_migration?})\nputs %Q(queue: ready=\#{SolidQueue::ReadyExecution.count} failed=\#{SolidQueue::FailedExecution.count} processes=\#{SolidQueue::Process.pluck(:kind).tally})\n"' on app version efac78fe91ec70767dd94e5f1f14961d61ea0ecd
[2026-11-10T14:36:10Z] [sarnolds@miuandes.cl] [web] Executed cmd 'bin/rails runner "puts %Q(jobs total=\#{SolidQueue::Job.count} finished=\#{SolidQueue::Job.finished.count} ready=\#{SolidQueue::ReadyExecution.count} scheduled=\#{SolidQueue::ScheduledExecution.count} claimed=\#{SolidQueue::ClaimedExecution.count} failed=\#{SolidQueue::FailedExecution.count}); puts %Q(repair 17: photos=\#{Repair.find(17).photos.count} state=\#{Repair.find(17).state})"' on app version efac78fe91ec70767dd94e5f1f14961d61ea0ecd
[2026-11-10T14:36:28Z] [sarnolds@miuandes.cl] [web] Executed cmd 'bin/rails runner "puts SolidQueue::Job.group(:class_name).count.inspect; puts %Q(finished=\#{SolidQueue::Job.finished.count} ready=\#{SolidQueue::ReadyExecution.count} scheduled=\#{SolidQueue::ScheduledExecution.count} claimed=\#{SolidQueue::ClaimedExecution.count} failed=\#{SolidQueue::FailedExecution.count})"' on app version efac78fe91ec70767dd94e5f1f14961d61ea0ecd
[2026-11-10T14:38:51Z] [sarnolds@miuandes.cl] Pulled image with version 9cdea6ca19bdb2ae5514123a193d87915d097b1d
[2026-11-10T14:39:06Z] [sarnolds@miuandes.cl] [web] Booted app version 9cdea6ca19bdb2ae5514123a193d87915d097b1d
[2026-11-10T14:39:20Z] [sarnolds@miuandes.cl] Tagging sarnolds/webtech_wheelhouse:9cdea6ca19bdb2ae5514123a193d87915d097b1d as the latest image
[2026-11-10T14:39:21Z] [sarnolds@miuandes.cl] Pruned containers
[2026-11-10T14:39:22Z] [sarnolds@miuandes.cl] Pruned images
[2026-11-10T14:39:39Z] [sarnolds@miuandes.cl] [web] Executed cmd 'bin/rails runner "r = Repair.find(17); puts %Q(repair 17: state=\#{r.state} photos=\#{r.photos.count} files_on_disk=\#{r.photos.count { |p| p.blob.service.exist?(p.blob.key) }} accounts=\#{User.count})"' on app version 9cdea6ca19bdb2ae5514123a193d87915d097b1d
[2026-11-10T14:39:52Z] [sarnolds@miuandes.cl] [web] Executed cmd 'bin/rails runner "r = Repair.find(17); puts %Q(repair 17: state=\#{r.state} photos=\#{r.photos.count} files_on_disk=\#{r.photos.count { |p| p.blob.service.exist?(p.blob.key) }} accounts=\#{User.count})"' on app version 9cdea6ca19bdb2ae5514123a193d87915d097b1d
[2026-11-10T14:40:41Z] [sarnolds@miuandes.cl] Pull db accessory image
[2026-11-10T14:40:43Z] [sarnolds@miuandes.cl] Stopped db accessory
[2026-11-10T14:40:44Z] [sarnolds@miuandes.cl] Remove db accessory container
[2026-11-10T14:40:46Z] [sarnolds@miuandes.cl] Booted db accessory
[2026-11-10T14:43:00Z] [sarnolds@miuandes.cl] [web] Executed cmd 'bin/rails runner "r = Repair.find(17); puts %Q(repair 17: state=\#{r.state} photos=\#{r.photos.count} files=\#{r.photos.count { |p| p.blob.service.exist?(p.blob.key) }} | queue failed=\#{SolidQueue::FailedExecution.count} ready=\#{SolidQueue::ReadyExecution.count} processes=\#{SolidQueue::Process.count})"' on app version 9cdea6ca19bdb2ae5514123a193d87915d097b1d
[2026-11-10T14:44:36Z] [sarnolds@miuandes.cl] [web] Renaming container efac78fe91ec70767dd94e5f1f14961d61ea0ecd to efac78fe91ec70767dd94e5f1f14961d61ea0ecd_replaced_662e428f42e74620
[2026-11-10T14:44:38Z] [sarnolds@miuandes.cl] [web] Booted app version efac78fe91ec70767dd94e5f1f14961d61ea0ecd
[2026-11-10T14:44:47Z] [sarnolds@miuandes.cl] Tagging sarnolds/webtech_wheelhouse:efac78fe91ec70767dd94e5f1f14961d61ea0ecd as the latest image
[2026-11-10T14:46:00Z] [sarnolds@miuandes.cl] Pulled image with version 9cdea6ca19bdb2ae5514123a193d87915d097b1d
[2026-11-10T14:46:10Z] [sarnolds@miuandes.cl] [web] Renaming container 9cdea6ca19bdb2ae5514123a193d87915d097b1d to 9cdea6ca19bdb2ae5514123a193d87915d097b1d_replaced_1b3357fa2e81f020
[2026-11-10T14:46:12Z] [sarnolds@miuandes.cl] [web] Booted app version 9cdea6ca19bdb2ae5514123a193d87915d097b1d
[2026-11-10T14:46:20Z] [sarnolds@miuandes.cl] Tagging sarnolds/webtech_wheelhouse:9cdea6ca19bdb2ae5514123a193d87915d097b1d as the latest image
[2026-11-10T14:46:22Z] [sarnolds@miuandes.cl] Pruned containers
[2026-11-10T14:46:23Z] [sarnolds@miuandes.cl] Pruned images
```
