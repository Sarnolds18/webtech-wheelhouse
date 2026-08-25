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