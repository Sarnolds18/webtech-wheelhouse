# Questions the description does not answer

Three things I would ask the owner. Each one changes the model depending on the answer, so for each I wrote down what I assumed in order to keep working.

## 1. If the mechanic opens the bike and finds something worse, do you quote again?

The description covers one call: look at it properly, phone the customer, tell them the price, wait for a yes. It says nothing about what happens when the bottom bracket turns out to be gone once the crank is off.

**What I assumed.** One quote per repair. The quote is stored as fields on `repairs` — `quoted_at`, `quoted_amount`, `quote_response`, `responded_at` — because a repair has at most one of each.

**What changes if the answer is yes.** A repair can have several quotes, so those four fields come out of `repairs` and become a `quotes` table with a foreign key back to it, one row per call. `repairs` then needs a way to say which quote is the one in force, and the lifecycle gains a loop: a repair already `in_progress` can return to `quoted`.

## 2. When someone sells a bike, do you want to record that it changed hands?

The owner says people sell bikes and that the second owner deserves to know the fork was replaced. He never says the shop writes the sale down anywhere — the new owner simply walks in one day with a bike the shop has seen before.

**What I assumed.** The shop does not track ownership as an event. `bikes.customer_id` holds whoever owns the bike now, and every `repairs` row also stores the customer who brought it in that day. The history of the bike stays attached to the bike, and each past visit still shows the right person, even after a sale.

**What changes if the answer is yes.** `bikes.customer_id` disappears and a `bike_ownerships` table takes its place — bike, customer, start date, end date. The current owner becomes the row with no end date. The redundancy between the two customer columns goes away, and asking who owned the bike in March 2024 becomes answerable, which it is not today.

## 3. When you look at an old repair and the price is low, do you need to know whether it was a discount or just the old list?

The list goes up every January, and the shop sometimes charges a regular less than the list. Both produce the same thing on paper: a line cheaper than the price on the wall today. The description never says the owner needs to tell them apart.

**What I assumed.** He does not. `repair_services.charged_price` stores what was actually charged and nothing else. Old invoices are frozen and discounts are possible, which is everything the description asks for.

**What changes if the answer is yes.** `services.price` is no longer enough. Prices need a `service_prices` table with a validity range, so every line can be compared against the list price in force on the day of the repair. The difference between the two is then the discount, and it becomes a real number instead of a guess.
## 4. When a new account is created, which role does it get?

Every account has a role: owner, mechanic or counter. A new account gets one before anyone has said who the person is, so the default has to be the one that can do the least harm.

**What I decided.** The default is `mechanic`. The mechanic works on the bike in front of them: reads the repair, writes the diagnosis, does the work. The person at the counter takes the customer in, holds their phone number, quotes, hands the bike back and charges for it — customers' data and money. The owner does everything. Of the three, the mechanic needs the least, so an account nobody has looked at yet starts there, and the owner raises it from the seed or the console.

**What changes if the answer is different.** Only the default of the `role` column, in a migration. The accounts that already exist keep their role.

## 5. Which actions ask no policy, and why

Every action of every controller asks its policy, and every index is built from a policy scope:
`ApplicationController` checks both after each action (`verify_authorized`, `verify_policy_scoped`), so an
action that forgets raises an error instead of answering, and a new controller is covered without a line
written in it. These actions skip the check, because they are about the session itself and there is no
record and no role to ask about yet:

| Controller | Actions | Why it is public |
|---|---|---|
| `SessionsController` | `new`, `create`, `destroy` | Signing in is done by someone with no account yet in the session; signing out ends the session the request carries. |
| `RegistrationsController` | `new`, `create` | Signing up is done by someone with no account. The account made gets the default role. |
| `PasswordsController` | `new`, `create`, `edit`, `update` | Whoever forgot their password has no session; the reset link's token is what proves who they are. |

The price list (`ServicesController#index` and `#show`) is open to visitors, but it is not on this list:
it asks `ServicePolicy`, which answers yes to everyone. The API (`/api/v1`) has its own base controller,
outside `ApplicationController`, and keeps its token check.

## 6. Another mechanic's repair: 403, not 404

A mechanic who changes the id in the URL to a repair that is not theirs gets the `403` page, for the
repair's page and for its edit form alike. The repair exists and the mechanic already knows it does
(they work in the same workshop and can read the staff's names), so a `404` would hide nothing; the
`403` says what actually happened. The scope and `RepairPolicy#show?` give the same answer, so the
repairs a mechanic is refused are exactly the ones missing from their index.

## 7. Plain HTTP on the production IP (Lab 13)

**What I decided.** The lab application is reached at `http://<PUBLIC_IP>` on port 80, without a
domain or TLS certificate. Kamal's proxy has `ssl: false`. The instructor permits AWS EC2 in place
of DigitalOcean as long as the same deployment and persistence requirements can be demonstrated.

In `config/environments/production.rb` these two generated settings changed from `true` to `false`:

| Setting | What it did | Why it is disabled for this lab |
|---|---|---|
| `config.assume_ssl` | Told Rails that the proxy had already terminated TLS, so the original request was HTTPS even though the proxy-to-Rails connection was HTTP. This describes a trusted proxy; it does not encrypt traffic itself. | The client-to-proxy connection is HTTP too. Pretending it was HTTPS would produce incorrect secure-request behavior, including cookies or URLs intended for HTTPS. |
| `config.force_ssl` | Installed Rails' SSL middleware: redirected HTTP to HTTPS, marked cookies `Secure`, and added HSTS to HTTPS responses so browsers would remember to use HTTPS. | There is no HTTPS endpoint. Requests must stay on HTTP, and session cookies must be sent over HTTP for sign-in to work. With this middleware absent, Rails does not add those redirects, the automatic `Secure` cookie flag or HSTS. |

No extra `ssl_options` exception for `/up` is necessary: the whole application uses HTTP, including
the health check. Authentication still uses signed cookies with `HttpOnly` and `SameSite=Lax`, and
CSRF checks and Pundit authorization remain enabled. These protections do not encrypt a connection.

### What the counter gives up

An attacker on the same Wi-Fi who can intercept the counter's traffic can read passwords submitted
to sign in or sign up, session cookies, password-reset tokens in URLs, API bearer tokens, customers'
details, diagnoses and photos. A signed cookie cannot be forged without the signing key, but a
captured cookie can be replayed to impersonate that account. A stolen API token permits the API's
protected operations. An attacker who can alter traffic can also replace responses or form contents,
inject scripts and change submitted data. `HttpOnly`, CSRF checks and role permissions do not prevent
these attacks on an unencrypted connection.

The browser may warn about an insecure site or try HTTPS first because of its own HTTPS-first mode.
That browser behavior is distinct from a server redirect. The production evidence must show that
`curl -I http://<PUBLIC_IP>/up` returns `200` with no `Location: https://...`, and that a request for a
closed page redirects to the HTTP sign-in URL.

### The published price list and mixed content

GitHub Pages serves the personal page over HTTPS. If its `API_URL` is temporarily pointed at the
production HTTP IP, the browser blocks its `fetch` as mixed content, before CORS could make the
response available. A Chrome-style diagnostic is:

```text
Mixed Content: The page at 'https://sarnolds18.github.io/webtech-lab-01/' was loaded over HTTPS,
but requested an insecure resource 'http://<PUBLIC_IP>/api/v1/services'. This request has been
blocked; the content must be served over HTTPS.
```

This is an illustrative diagnostic, not captured production evidence. The exact message and IP
will be recorded after the real deployment. The committed personal page keeps its existing API URL.
For the lab's production API demonstration, serve a temporary local copy of the page from
`http://localhost:8000`, set that copy's `API_URL` to `http://<PUBLIC_IP>/api/v1`, and keep that origin
in the API's CORS allowlist. The loopback URL used by the existing published page is treated
differently by browsers from a public HTTP IP.

### How to restore HTTPS

Provide a stable address and a browser-trusted TLS certificate valid for it (normally a domain
pointing to the server), enable HTTPS at the proxy, and restore `force_ssl = true`. Use
`assume_ssl = true` when the trusted proxy terminates TLS before forwarding to Rails. Generate mail
links with `https://`, verify `Secure` cookies and HSTS, and point the published page at the HTTPS
API. The resulting connection protects traffic confidentiality and integrity and removes this
mixed-content block.

References: [Rails SSL middleware](https://api.rubyonrails.org/classes/ActionDispatch/SSL.html),
[mixed content](https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Mixed_content), and
[HSTS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Strict-Transport-Security).
