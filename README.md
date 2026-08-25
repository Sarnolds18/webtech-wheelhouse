# webtech-wheelhouse

Wheelhouse is a neighbourhood bicycle repair shop that currently runs on paper tags tied to handlebars and a notebook per mechanic. When a customer phones to ask whether their bike is ready, whoever answers has to walk to the workshop and find out. This repository holds the analysis that turns that shop into a system: the stories, the domain model, the open questions and the screens.

No code yet. Lab 4 builds the Rails application in this same repository, from the model documented here.

## Who uses it

- **The owner** — sets the price list, watches what is late, looks up what was done to a bike on its last visit.
- **The three mechanics** — see what is waiting for them, write the diagnosis, add services and set what is actually charged.
- **The counter** — takes bikes in, answers the phone, records whether the customer accepted the quote, hands bikes back.
- **The customer** — brings the bike, is told what it will cost, says yes or no. Not a user of the system: nothing is public except the price list.
- **Website visitors** — see the list of services and their prices, and nothing else.

## Documents

- [User stories](docs/user-stories.md) — what the system does, for whom and why, with acceptance criteria on four of them.
- [Domain model](docs/domain-model.md) — the diagram and its DBML, the lifecycle of a repair, the entity-to-story trace, and the two modelling decisions worth defending.
- [Decisions](docs/decisions.md) — three questions the owner's description does not answer, what was assumed instead, and what would change.
- [Wireframes](docs/wireframes.md) — four low-fidelity screens and the navigation graph.