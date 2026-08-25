# User Stories

Roles: the owner, the three mechanics, the counter (his daughter), the customer, and people visiting the website.

The customer is a role in the process, not a user of the system. The owner is explicit that nothing but the price list is public, so the customer's stories are about the shop dealing with them, not about them logging in. Whether that should change is in `decisions.md`.

## Counter

**1.** As counter staff, I want to register an arriving bike with the customer's name and phone, the model, the serial number and the day we promise it, so that I can tell two identical bikes apart when they leave.

Acceptance criteria:
- Saving with name, phone, model, serial number and promised date creates a repair in state *received*.
- Saving without a serial number fails and shows why.
- A serial number that already exists attaches the repair to that bike instead of creating a new one.
- The repair appears in the list of bikes in the shop.

**2.** As counter staff, I want to look up a repair by name, phone or serial number and see its state, so that I can answer the phone without walking to the workshop.

Acceptance criteria:
- Searching a serial number of a bike in the shop shows its state and promised date.
- Searching a phone with two bikes in the shop shows both, each with its serial number.
- A search with no matches says nothing was found instead of showing an empty table.
- The total shown is the same one the mechanic sees.

**3.** As counter staff, I want to record whether the customer accepted or declined the quote, so that the mechanic knows whether to start or leave the bike alone.

**4.** As counter staff, I want to mark a bike as collected, so that it stops showing up among the bikes still here.

## Mechanic

**5.** As a mechanic, I want to see the bikes waiting for me and their state, so that I don't need my own notebook.

**6.** As a mechanic, I want to write the diagnosis as free text of any length, so that whoever reads it later understands what was wrong.

**7.** As a mechanic, I want to add services from the wall list to a repair and change the price charged on each, so that I can charge a regular less without touching the list.

Acceptance criteria:
- Adding a service fills in the current list price.
- Lowering a line's price stores that value and leaves the list price unchanged.
- The total is the sum of the charged prices, not the list prices.
- A repair with no services shows a total of zero and says no services have been added yet.

**8.** As a mechanic, I want to mark a repair as finished, so that the counter can tell the customer it's ready.

## Owner

**9.** As the owner, I want to change the price of a service, so that new repairs use the new price and last year's invoices stay as they were.

**10.** As the owner, I want the arrival photos attached to the repair, so that nobody argues later about who made the scratch.

**11.** As the owner, I want repairs past their promised date and not yet collected to be flagged, so that I see it before the customer phones me.

Acceptance criteria:
- A repair past its promised date and not collected shows as late.
- A repair promised for today does not show as late.
- A collected repair never shows as late, even if the date passed.
- When nothing is late, the screen says so instead of leaving the area empty.

## Customer

**12.** As a customer, I want to be told what the repair will cost before any work starts, so that I can decide whether to go ahead.

**13.** As a customer, I want to decline the quote and get my bike back the way I left it, so that I am not charged for work I did not agree to.

## Website visitor

**14.** As a visitor, I want to see the services and their prices, so that I don't have to phone to ask what a tune-up costs.

## Too big

> As the owner, I want the full history of a bike, so that when a customer comes back I can see what we did to it last time.

I can't finish this in one go and I can't estimate it — "the full history" is three different things, and each one is worth having on its own. 15 works without 16, and 16 without 17.

**15.** As the owner, I want to see the list of past repairs on a bike with their dates, so that I can tell at a glance whether we have seen it before.

**16.** As the owner, I want to open one of those past repairs and read its diagnosis, services and photos, so that I know exactly what was done and what it cost.

**17.** As the owner, I want that history to include repairs done while the bike belonged to someone else, so that the second owner learns the fork was replaced.

**18.** As the owner, I want an invoice issued when the bike is collected, so that what we charged that day stays on record even after the price list changes.