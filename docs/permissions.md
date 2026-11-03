# Who may do what

What each role may do in Wheelhouse, one table per resource with pages. Every cell is what the policy
in `app/policies/` answers; the policy is the only place the rule is written, and the controllers, the
indexes and the views all ask it.

- **Owner**, **Counter** and **Mechanic** are the three roles of an account (`users.role`). An account
  made on the sign-up page gets the default role, **mechanic**, and belongs to no member of the staff.
- **Visitor** is someone with no session. Apart from the price list, a visitor is sent to sign in and
  never reaches a policy.
- **Own repair**: a repair whose mechanic is the member of the staff joined to the account. An account
  with the role `mechanic` that belongs to no member of the staff has no own repairs.
- **Handed back**: a repair in the state `collected`, the last state of the lifecycle in
  `docs/domain-model.md`.
- Anything not allowed in a table is refused with a `403` page (`app/policies/application_policy.rb`
  refuses every action whose method was not written).

## Services (the price list) — `ServicePolicy`

| Action | Owner | Counter | Mechanic | Visitor |
|---|---|---|---|---|
| List (`index`) | Yes | Yes | Yes | Yes |
| Read one (`show`) | Yes | Yes | Yes | Yes |
| Create (`new`, `create`) | Yes | No | No | No (sent to sign in) |
| Edit (`edit`, `update`) | Yes | No | No | No (sent to sign in) |
| Delete (`destroy`) | Yes | No | No | No (sent to sign in) |

## Staff — `MechanicPolicy`

| Action | Owner | Counter | Mechanic |
|---|---|---|---|
| List (`index`) | Yes | Yes | Yes |
| Read one (`show`) | Yes | Yes | Yes — the repairs listed on the page are only the ones the reader may read |
| Create (`new`, `create`) | Yes | No | No |
| Edit (`edit`, `update`) | Yes | No | No |
| Delete (`destroy`) | Yes | No | No |

## Customers — `CustomerPolicy`

| Action | Owner | Counter | Mechanic |
|---|---|---|---|
| List (`index`) | Yes, every customer | Yes, every customer | No |
| Read one (`show`) | Yes | Yes | No |
| Create (`new`, `create`) | Yes | Yes | No |
| Edit (`edit`, `update`) | Yes | Yes | No |
| Delete (`destroy`) | Yes | No | No |

## Bikes — `BikePolicy`

| Action | Owner | Counter | Mechanic |
|---|---|---|---|
| List (`index`) | Yes, every bike | Yes, every bike | No |
| Read one (`show`) | Yes | Yes | No |
| Create (`new`, `create`) | Yes | Yes | No |
| Edit (`edit`, `update`) | Yes | Yes | No |
| Delete (`destroy`) | Yes | No | No |

## Repairs — `RepairPolicy`

| Action | Owner | Counter | Mechanic |
|---|---|---|---|
| List (`index`) | Yes, every repair | Yes, every repair | Yes, only their own repairs |
| Read one (`show`) | Yes, every repair | Yes, every repair | Only their own repairs |
| Take in (`new`, `create`) | Yes | Yes | No |
| Edit (`edit`, `update`) | Yes, every repair | Every repair not handed back | Their own repairs not handed back |
| Delete (`destroy`) | Yes | No | No |
| Remove an intake photo (`Repairs::PhotosController#destroy`) | Yes, every repair | Every repair not handed back | No |

Every other page that lists repairs (a bike's page, a member of the staff's page) uses the same scope as
the index, and the state and overdue filters of the index are chained on it.

### Fields of the repair's form

| Field | Owner | Counter | Mechanic |
|---|---|---|---|
| State | Yes | Yes | Yes |
| Diagnosis | Yes | Yes | Yes |
| Add intake photos | Yes | Yes | Yes |
| Bike, mechanic, received, promised day | Yes | Yes | No |
| Quote (date, amount, answer, answered) | Yes | Yes | No |
| Services charged and their prices | Yes | Yes | No |
| Finished, collected | Yes | Yes | No |
| Account that took it in | No — read from the session when the repair is created | No | No |

A field outside the person's list that arrives anyway (added from DevTools) is dropped and the rest of
the request goes on.

### What the repair's page links

Everyone who may read a repair sees its bike and its customer. They are links only for a person who may
open the bike and the customer (owner and counter).

## Workshop pages (Home, Visit, About) — `PagePolicy`

| Action | Owner | Counter | Mechanic |
|---|---|---|---|
| Home, Visit, About | Yes | Yes | Yes |

## Accounts

No page lists, edits or deletes accounts, for any role. Signing in and out, signing up and the
forgotten-password pages ask no policy: they are the public actions listed in `docs/decisions.md`.
