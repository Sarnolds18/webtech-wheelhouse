# Deployment

Deployment preparation is in progress. No production URL, deploy SHA, rollback or terminal evidence
has been recorded yet. These must be completed from the actual server before submission.

The instructor allows an alternative cloud provider if every lab requirement remains demonstrable.
The selected target is AWS EC2 with Ubuntu, at least 2 GB RAM and an x86-64 CPU. The region,
instance type and public IP will be recorded after the instance is created.

## Infrastructure

Kamal 2 builds the Rails image locally with Docker Buildx for `amd64`, pushes it to Docker Hub,
and deploys it over SSH as `ubuntu`. The server needs Docker installed and that user must be able
to use it. The laptop needs Docker with Buildx, Ruby and the gems from `bundle install`.

| Container | Runs | Listening ports |
|---|---|---|
| `kamal-proxy` | Routes HTTP requests to Rails | Host ports 80 and 443; the lab uses HTTP on 80 |
| `webtech_wheelhouse-web-<SHA>` | Rails through Thruster, with Solid Queue in Puma | Thruster on 80 inside the Kamal network; Puma on 3000 inside the container |
| `webtech_wheelhouse-db` | PostgreSQL 18, as a Kamal accessory | 5432 inside the Kamal network; no host port published |

The EC2 security group must allow inbound HTTP on 80 and SSH on 22 from the administrator's IP.
It must not allow inbound PostgreSQL on 5432. `keys_only` selects the client's SSH key; refusing
password authentication must also be configured and verified on the server itself.

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

The image's entrypoint runs `bin/rails db:prepare` before Rails starts. On the first boot it creates
missing databases, loads their schemas, applies migrations and runs the seed when the primary
database is initialized. Subsequent boots prepare existing databases without reseeding them.
Do not run a separate `db:seed` after the first boot. Production password handling is prepared
in a later step.

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

The registry token needs pull and push permission for the account's `webtech_wheelhouse` image.
Keep the database password in a password manager: changing an exported variable does not change
the password of an already initialized PostgreSQL cluster.

| Secret | Where its value is kept | How it reaches its destination |
|---|---|---|
| `KAMAL_REGISTRY_PASSWORD` | Password manager; exported locally | `.kamal/secrets` reads it; Kamal logs in to Docker Hub on the laptop and server |
| `RAILS_MASTER_KEY` | Ignored local `config/master.key`; exported locally | Kamal injects it into the Rails container at runtime |
| `WEBTECH_WHEELHOUSE_DATABASE_PASSWORD` | Password manager; exported locally | Injected into Rails under this name and into PostgreSQL as `POSTGRES_PASSWORD` |
| Brevo SMTP login and SMTP key | Encrypted `config/credentials.yml.enc`, under `smtp.user_name` and `smtp.password` | Rails decrypts them in the container with `RAILS_MASTER_KEY`; no environment variable of their own |
| SSH private key | Private file outside the repository | Kamal reads the path in `WHEELHOUSE_SSH_KEY`; the key is not copied into the image |

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

Production password handling follows in a separate commit. Actual deploys, rollback, persistence checks and sanitized
terminal evidence will be recorded here afterwards.
