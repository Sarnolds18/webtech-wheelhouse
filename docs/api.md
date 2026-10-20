# The Wheelhouse API

Two programs that are not a browser read Wheelhouse: the shop's **website**, which shows the price list
on another origin, and the shop's **accounting program**, which reads the repairs that were handed back
and what was charged on each one. The owner also adds services to the price list from a script. They all
talk to this API.

- **Base URL**: `http://localhost:3000/api/v1` while developing. The version is a segment of the path;
  a change that breaks a client goes to `/api/v2`, and `/api/v1` keeps answering as documented here.
- **Every answer is JSON** (`Content-Type: application/json`), errors included, whatever the request's
  `Accept` header says. The API never answers an HTML page or a redirect.
- **No session, no cookies, no CSRF token.** A program sends what it needs in each request.

## Authentication

Reading the price list is open. Reading repairs and adding a service need the shop's **API token**, sent
in the `Authorization` header with the `Bearer` scheme:

```
Authorization: Bearer <token>
```

A token in the query string or in the body is not read. Without the header, or with another token, the
request is refused with `401` before anything else happens. The token lives in the application's encrypted
credentials (`api_token`); the [README](../README.md#the-api) says how to set it.

## Routes

| Verb   | Path                     | Token | Answers                                                       |
|--------|--------------------------|-------|---------------------------------------------------------------|
| `GET`  | `/api/v1/services`       | no    | `200` the collection of services                              |
| `GET`  | `/api/v1/services/:id`   | no    | `200` one service · `404`                                     |
| `POST` | `/api/v1/services`       | yes   | `201` the new service · `400` · `401` · `422`                 |
| `GET`  | `/api/v1/repairs`        | yes   | `200` the collection of repairs · `400` (bad `state`) · `401` |
| `GET`  | `/api/v1/repairs/:id`    | yes   | `200` one repair · `401` · `404`                              |

Any other path or verb under `/api/v1` answers `404` with the error document. There is no `new` and no
`edit`: a program does not need a form.

### `GET /api/v1/services`

The whole price list, ordered by category and then by name — the same order as the wall list on the
shop's Services page. No pages: the collection is the list.

### `GET /api/v1/repairs?state=…`

The repairs, newest first (by the moment they came in). No pages. The optional `state` parameter keeps
only the repairs in that state. Its values are the lifecycle's states, as listed in
[`domain-model.md`](domain-model.md): `received`, `diagnosed`, `quoted`, `approved`, `declined`,
`in_progress`, `finished`, `collected`. Any other value answers `400`, and the message lists the states
that exist. The accounting program asks for `?state=collected`: the repairs that were handed back.

### `POST /api/v1/services`

The body is JSON, with the attributes inside a `service` key (the attributes alone, without the key, are
accepted too):

```json
{ "service": { "name": "Valve core replacement", "price": "3000", "category": "Tires & tubes" } }
```

Only `name`, `price` and `category` are read; anything else in the body is ignored. `category` is
optional. On success the answer is `201 Created`, its body is the new service's document, and its
`Location` header is the new service's full URL in the API (`http://localhost:3000/api/v1/services/:id`). A body with none of these
attributes, an empty body or a body that is not JSON answers `400`; a service the shop's rules refuse
(no name, a name already on the list, a price that is not above zero) answers `422` with the same
sentences the form on the website shows.

## Documents

### A service

`GET /api/v1/services/47` — and each element of `GET /api/v1/services`, and the body of a `201`:

```json
{
  "id": 47,
  "name": "Brake adjustment",
  "price": "12000.00",
  "category": "Brakes",
  "times_charged": 2
}
```

| Key             | Type             | Meaning                                                        |
|-----------------|------------------|----------------------------------------------------------------|
| `id`            | number           | Use it in `/api/v1/services/:id`.                               |
| `name`          | string           | As it appears on the wall list.                                 |
| `price`         | string           | Today's list price, in Chilean pesos (see **Decisions**).       |
| `category`      | string or `null` | The group it is listed under.                                   |
| `times_charged` | number           | How many repairs this service has been charged on. Not a column: it is counted, so the client doesn't have to ask twice. |

The three actions answer exactly this shape, so a client parses one document.

### A repair

`GET /api/v1/repairs/44`:

```json
{
  "id": 44,
  "state": "collected",
  "received_on": "2026-09-15",
  "promised_on": "2026-09-20",
  "collected_on": "2026-09-22",
  "bike": {
    "brand": "Trek",
    "model": "Marlin",
    "serial_number": "TM-2024-0114"
  },
  "customer": {
    "name": "Agustín Rivas"
  },
  "lines": [
    { "service": "Cassette replacement", "charged_price": "22000.00" },
    { "service": "Gear adjustment", "charged_price": "15000.00" }
  ],
  "total": "37000.00",
  "overdue": false,
  "quote_response": "approved"
}
```

| Key              | Type             | Meaning                                                                 |
|------------------|------------------|-------------------------------------------------------------------------|
| `id`             | number           | Use it in `/api/v1/repairs/:id`.                                         |
| `state`          | string           | Where the repair is in its lifecycle (one of the states above).          |
| `received_on`    | date             | The day the bike came in.                                                |
| `promised_on`    | date             | The day the shop promised it back.                                       |
| `collected_on`   | date or `null`   | The day it was handed back; `null` while it hasn't been.                 |
| `bike`           | object           | The bike's brand, model and serial number.                               |
| `customer`       | object           | The name of the customer who brought the bike in.                        |
| `lines`          | list             | Each service charged on the repair, with the price **charged**, which can differ from today's list price. |
| `total`          | string           | The sum of the lines' charged prices. Not a column.                      |
| `overdue`        | boolean          | `true` when the promised day has passed and the bike hasn't been handed back. Not a column. |
| `quote_response` | string or `null` | The customer's answer to the quote: `approved`, `declined`, or `null` when there was no quote or no answer yet. |

Dates are `YYYY-MM-DD`, the day in the shop's time zone (Santiago, Chile).

### A collection of repairs

`GET /api/v1/repairs` (and `?state=…`) answers a JSON array of repair documents, newest first. Shortened
here to two:

```json
[
  {
    "id": 45,
    "state": "received",
    "received_on": "2026-10-06",
    "promised_on": "2026-10-11",
    "collected_on": null,
    "bike": { "brand": "Scott", "model": "Aspect", "serial_number": "SA-2022-0009" },
    "customer": { "name": "Constanza Bravo" },
    "lines": [
      { "service": "Tire replacement", "charged_price": "18000.00" }
    ],
    "total": "18000.00",
    "overdue": true,
    "quote_response": null
  },
  {
    "id": 44,
    "state": "collected",
    "received_on": "2026-09-15",
    "promised_on": "2026-09-20",
    "collected_on": "2026-09-22",
    "bike": { "brand": "Trek", "model": "Marlin", "serial_number": "TM-2024-0114" },
    "customer": { "name": "Agustín Rivas" },
    "lines": [
      { "service": "Cassette replacement", "charged_price": "22000.00" },
      { "service": "Gear adjustment", "charged_price": "15000.00" }
    ],
    "total": "37000.00",
    "overdue": false,
    "quote_response": "approved"
  }
]
```

A filter that matches nothing answers `200` with `[]`.

### An error

Every error, whatever its status, is an object with one key, `errors`, whose value is a list of strings.
A client handles every error in one place: check the status, then show the strings.

```json
{ "errors": ["Name can't be blank", "Price must be greater than 0"] }
```

| Status | When                                                        | Example message                                                     |
|--------|-------------------------------------------------------------|---------------------------------------------------------------------|
| `400`  | The body carries nothing the API can read                   | `The body has no attributes of a service` · `The body is not valid JSON` |
| `400`  | The `state` filter has a value that does not exist          | `State must be one of: received, diagnosed, quoted, approved, declined, in_progress, finished, collected` |
| `401`  | The token is missing or wrong, on a route that needs it     | `A valid token is required in the Authorization header, with the Bearer scheme` |
| `404`  | There is no record with that id, or no such route           | `Service 999 does not exist` · `No route matches DELETE /api/v1/services/1` |
| `422`  | A validation failed                                         | `Name has already been taken`                                       |

## Decisions

### A price travels as a string

Every price — a service's `price`, a line's `charged_price`, a repair's `total` — travels as a **string
with two decimals**: `"12000.00"`. The database keeps money as an exact decimal (`decimal(10,2)`); a JSON
number is read by most clients (JavaScript included) as a binary floating-point number, which can't hold
every decimal exactly. A string carries the exact value, and the client decides how to turn it into money:
the website does `Number(price)` and formats it as Chilean pesos, without decimals, because the shop's
prices are whole pesos.

### What the repair document leaves out, and why

The accounting program needs to know what was done to which bike, for whom, when, and what was charged.
Everything else stays in the shop:

- **No foreign keys** (`bike_id`, `customer_id`, `mechanic_id`, …). An id means nothing to another
  program; the bike and the customer are inside the document, with the names a person reads.
- **No customer phone.** A customer's contact details are personal data the accounting program has no
  use for; the name is enough to read an invoice.
- **No mechanic.** Who worked on the bike is the workshop's internal business, not accounting's.
- **No diagnosis and no intake photos.** They are the mechanic's notes and pictures, they can be long
  (the diagnosis is formatted HTML; photos are files), and nothing about what was charged depends on them.
- **No quote details** (`quoted_amount`, `quoted_at`, `responded_at`). What counts for accounting is what
  was charged (`lines`, `total`); the customer's answer (`quote_response`) is kept because it explains a
  declined repair with nothing charged.
- **No exact times and no record timestamps** (`received_at`, `collected_at`, `created_at`,
  `updated_at`). Accounting works by day, so the moments are given as days (`received_on`,
  `collected_on`).

### The rest

- **Fixed number of queries.** Both collections load everything their documents read up front, so the
  number of database queries does not grow with the number of repairs, lines or services.
- **The website is the only other origin allowed.** Browsers on `https://sarnolds18.github.io` (the
  published page) and `http://localhost:8000` (where it is served while developing) may `GET` the
  services; no origin is allowed to send the token routes. Programs that are not browsers (`curl`, the
  accounting program) are not affected by this rule.
