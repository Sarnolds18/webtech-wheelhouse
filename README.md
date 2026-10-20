# Wheelhouse

Wheelhouse is a neighbourhood bicycle repair shop. This repository holds its Rails application: the
public pages — **Home**, **Services** (the shop's price list), **Visiting the workshop** (location, hours
and what happens when a bike comes in) and **About** — and the pages the shop works with: **Customers**,
**Bikes**, **Repairs** and **Staff**. Every one of these records can be listed, viewed, created, edited
and deleted from the browser. A repair's form also records the services charged on it, the photos
taken when the bike came in (shown as thumbnails wherever repairs are listed) and the mechanic's
diagnosis, written with formatting.

Wheelhouse also answers programs that are not a browser, through a JSON API under `/api/v1`: the price
list is public, and the shop's website — on another origin — shows it; reading repairs and adding a
service need a token. See [The API](#the-api) below.

There is no login yet: every page is open to anyone who can reach the app. See `docs/` for the domain
model, user stories, wireframes and open design decisions the application is built towards.

- [`docs/domain-model.md`](docs/domain-model.md) — the database schema, and how it has changed since it
  was first designed
- [`docs/user-stories.md`](docs/user-stories.md) — who uses the shop's internal tools and why
- [`docs/wireframes.md`](docs/wireframes.md) — sketches of the screens those stories describe
- [`docs/decisions.md`](docs/decisions.md) — open questions for the owner and what was assumed instead
- [`docs/api.md`](docs/api.md) — the JSON API: its routes, the documents it answers, and why they look
  the way they do

## Prerequisites

- **Ruby 4.0.4** and **Rails 8.1** (`ruby -v`, `rails -v`)
- **Node 26.1.0** and npm — used to compile Bootstrap's Sass, not for application JavaScript
- **PostgreSQL**, running locally, with a role that can create databases
- **libvips**, the image library that makes the photos' thumbnails. Without it the app runs, but no
  thumbnail can be generated. Install it with your system's package manager:
  - Ubuntu / Debian / WSL: `sudo apt install libvips`
  - macOS (Homebrew): `brew install vips`

## Setup

```bash
git clone https://github.com/Sarnolds18/webtech-wheelhouse.git
cd webtech-wheelhouse

bundle install
npm install

bin/rails db:setup
```

`db:setup` creates the development database, loads `db/schema.rb` and runs `db/seeds.rb` — one command,
fresh clone to a seeded database. (`bin/rails db:reset` does the same on a database that already exists,
dropping it first.)

The seed attaches intake photos to most repairs, from the image files in `db/seeds/` (credits in
`db/seeds/CREDITS.md`). Uploaded files are stored on disk in `storage/`, which git ignores; running the
seed again replaces them rather than adding more.

## Running the app

```bash
bin/dev
```

This starts the Rails server and the Sass watcher together. Open **http://localhost:3000**.

(`bin/rails server` on its own also serves the app, but does not rebuild the CSS.)

## The API

The API runs inside the same Rails server, under `/api/v1`, so `bin/dev` (port **3000**) serves it too.
[`docs/api.md`](docs/api.md) describes every route and document.

### Setting the API token

Reading repairs and adding a service need a token. It is kept in the application's **encrypted
credentials** (`config/credentials.yml.enc`), under the key `api_token`, and never in the code. The key
that decrypts that file, `config/master.key`, is not in the repository, so a fresh clone can't read the
shop's credentials. Make your own instead:

```bash
rm config/credentials.yml.enc
bin/rails secret                          # prints a long random string: copy it
EDITOR="nano" bin/rails credentials:edit  # creates new credentials and a new config/master.key
```

In the editor, add one line with the string you copied, then save and close:

```yaml
api_token: paste-the-long-random-string-here
```

`config/master.key` is ignored by git: keep it to yourself. Don't commit the new
`config/credentials.yml.enc` back to this repository, nor the line `credentials:edit` may add to
`.gitignore`. (If you were given the shop's `master.key`, put it in `config/master.key` and skip these
steps.)

### Asking the API from the terminal

With the server running (`bin/dev`), the price list needs nothing:

```bash
curl http://localhost:3000/api/v1/services
curl http://localhost:3000/api/v1/services/1
```

The repairs need the token, in the `Authorization` header. Read it from the credentials into a shell
variable, so it doesn't end up typed in your history:

```bash
export WHEELHOUSE_TOKEN=$(bin/rails runner 'print Rails.application.credentials.api_token')

curl -H "Authorization: Bearer $WHEELHOUSE_TOKEN" "http://localhost:3000/api/v1/repairs?state=collected"
```

Adding a service to the price list works the same way:

```bash
curl -X POST http://localhost:3000/api/v1/services \
  -H "Authorization: Bearer $WHEELHOUSE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"service": {"name": "Valve core replacement", "price": "3000", "category": "Tires & tubes"}}'
```

### The price list on the website

The shop's price list is shown on a page published on GitHub Pages, which reads it from this API:
**https://sarnolds18.github.io/webtech-lab-01/** (its source is
[github.com/Sarnolds18/webtech-lab-01](https://github.com/Sarnolds18/webtech-lab-01)).

The page asks `http://localhost:3000/api/v1/services`, so **the API has to run on port 3000** on the same
computer that opens the page — `bin/dev` already does. The API only lets two origins read it from a
browser (`config/initializers/cors.rb`): the published page, and `http://localhost:8000`, where the page
is served while it's being developed (`python3 -m http.server 8000` in its folder). Recent versions of
Chrome ask for permission before a public site talks to `localhost`: allow it, or open the page in
Firefox.
