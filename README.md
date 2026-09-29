# Wheelhouse

Wheelhouse is a neighbourhood bicycle repair shop. This repository holds its Rails application: the
public pages — **Home**, **Services** (the shop's price list), **Visiting the workshop** (location, hours
and what happens when a bike comes in) and **About** — and the pages the shop works with: **Customers**,
**Bikes**, **Repairs** and **Staff**. Every one of these records can be listed, viewed, created, edited
and deleted from the browser, and a repair's form also records the services charged on it.

There is no login yet: every page is open to anyone who can reach the app. See `docs/` for the domain
model, user stories, wireframes and open design decisions the application is built towards.

- [`docs/domain-model.md`](docs/domain-model.md) — the database schema, and how it has changed since it
  was first designed
- [`docs/user-stories.md`](docs/user-stories.md) — who uses the shop's internal tools and why
- [`docs/wireframes.md`](docs/wireframes.md) — sketches of the screens those stories describe
- [`docs/decisions.md`](docs/decisions.md) — open questions for the owner and what was assumed instead

## Prerequisites

- **Ruby 4.0.4** and **Rails 8.1** (`ruby -v`, `rails -v`)
- **Node 26.1.0** and npm — used to compile Bootstrap's Sass, not for application JavaScript
- **PostgreSQL**, running locally, with a role that can create databases

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

## Running the app

```bash
bin/dev
```

This starts the Rails server and the Sass watcher together. Open **http://localhost:3000**.

(`bin/rails server` on its own also serves the app, but does not rebuild the CSS.)
