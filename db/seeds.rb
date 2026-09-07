# Wall list, staff, customers, bikes and repairs for Wheelhouse.
#
# Run with `bin/rails db:seed` (or `bin/rails db:setup` on a fresh database, which also creates
# the database and loads the schema). Safe to run more than once: it clears its own tables first
# in dependency order, so the row counts never grow on a second run.

ActiveRecord::Base.transaction do
  RepairService.delete_all
  Invoice.delete_all
  Repair.delete_all
  Bike.delete_all
  Service.delete_all
  Mechanic.delete_all
  BikeModel.delete_all
  Customer.delete_all

  # --- Staff -----------------------------------------------------------------

  mechanics = {
    fuentes: Mechanic.create!(name: "Matías Fuentes"),
    rojas: Mechanic.create!(name: "Ignacia Rojas"),
    soto: Mechanic.create!(name: "Benjamín Soto"),
    vidal: Mechanic.create!(name: "Camila Vidal") # the person at the counter
  }

  # --- Services (the wall list) -----------------------------------------------

  services = [
    { name: "Flat tire repair", price: 8_000, category: "Tires & tubes" },
    { name: "Tube replacement", price: 12_000, category: "Tires & tubes" },
    { name: "Tire replacement", price: 18_000, category: "Tires & tubes" },
    { name: "Tubeless conversion", price: 25_000, category: "Tires & tubes" },
    { name: "Brake adjustment", price: 12_000, category: "Brakes" },
    { name: "Brake pad replacement", price: 18_000, category: "Brakes" },
    { name: "Brake cable replacement", price: 15_000, category: "Brakes" },
    { name: "Gear adjustment", price: 15_000, category: "Drivetrain" },
    { name: "Chain replacement", price: 20_000, category: "Drivetrain" },
    { name: "Chain cleaning and lubrication", price: 10_000, category: "Drivetrain" },
    { name: "Cassette replacement", price: 22_000, category: "Drivetrain" },
    { name: "Wheel truing", price: 18_000, category: "Wheels & bearings" },
    { name: "Hub adjustment", price: 16_000, category: "Wheels & bearings" },
    { name: "Bottom bracket adjustment", price: 20_000, category: "Wheels & bearings" },
    { name: "Spoke replacement", price: 9_000, category: "Wheels & bearings" },
    { name: "Fork service", price: 40_000, category: "Suspension" },
    { name: "Shock service", price: 45_000, category: "Suspension" },
    { name: "Basic tune-up", price: 30_000, category: "Full service" },
    { name: "Full tune-up", price: 55_000, category: "Full service" },
    { name: "Bike assembly", price: 35_000, category: "Full service" },
    { name: "Safety inspection", price: 10_000, category: "Full service" }
  ].to_h { |attrs| [ attrs[:name], Service.create!(attrs) ] }

  # --- Customers ---------------------------------------------------------------

  customers = {
    javiera: Customer.create!(name: "Javiera Muñoz", phone: "+56 9 6123 4501"),
    cristobal: Customer.create!(name: "Cristóbal Reyes", phone: "+56 9 6123 4502"),
    florencia: Customer.create!(name: "Florencia Castro", phone: "+56 9 6123 4503"),
    tomas: Customer.create!(name: "Tomás Herrera", phone: "+56 9 6123 4504"),
    antonia: Customer.create!(name: "Antonia Silva", phone: "+56 9 6123 4505"),
    vicente: Customer.create!(name: "Vicente Morales", phone: "+56 9 6123 4506"),
    isidora: Customer.create!(name: "Isidora Contreras", phone: "+56 9 6123 4507"),
    maximiliano: Customer.create!(name: "Maximiliano Vargas", phone: "+56 9 6123 4508"),
    josefa: Customer.create!(name: "Josefa Tapia", phone: "+56 9 6123 4509"),
    agustin: Customer.create!(name: "Agustín Rivas", phone: "+56 9 6123 4510"),
    constanza: Customer.create!(name: "Constanza Bravo", phone: "+56 9 6123 4511"),
    diego: Customer.create!(name: "Diego Espinoza", phone: "+56 9 6123 4512") # no repairs yet
  }

  # --- Bike models ---------------------------------------------------------------

  bike_models = {
    trek_marlin: BikeModel.create!(brand: "Trek", name: "Marlin"),
    giant_escape: BikeModel.create!(brand: "Giant", name: "Escape"),
    specialized_rockhopper: BikeModel.create!(brand: "Specialized", name: "Rockhopper"),
    scott_aspect: BikeModel.create!(brand: "Scott", name: "Aspect"),
    cannondale_trail: BikeModel.create!(brand: "Cannondale", name: "Trail"),
    merida_big_nine: BikeModel.create!(brand: "Merida", name: "Big Nine"),
    bianchi_nirone: BikeModel.create!(brand: "Bianchi", name: "Via Nirone"),
    trek_domane: BikeModel.create!(brand: "Trek", name: "Domane"),
    giant_talon: BikeModel.create!(brand: "Giant", name: "Talon"),
    specialized_sirrus: BikeModel.create!(brand: "Specialized", name: "Sirrus")
  }

  # --- Bikes ---------------------------------------------------------------
  #
  # javiera_marlin and agustin_marlin2 are the same brand, model (Trek Marlin) — they differ only
  # in serial number, and belong to different customers.

  bikes = {
    javiera_marlin: Bike.create!(serial_number: "TM-2024-0113", bike_model_id: bike_models[:trek_marlin].id, customer_id: customers[:javiera].id),
    javiera_escape: Bike.create!(serial_number: "GE-2023-0087", bike_model_id: bike_models[:giant_escape].id, customer_id: customers[:javiera].id),
    cristobal_rockhopper: Bike.create!(serial_number: "SR-2022-0456", bike_model_id: bike_models[:specialized_rockhopper].id, customer_id: customers[:cristobal].id),
    florencia_aspect: Bike.create!(serial_number: "SA-2024-0021", bike_model_id: bike_models[:scott_aspect].id, customer_id: customers[:florencia].id),
    tomas_trail: Bike.create!(serial_number: "CT-2023-0198", bike_model_id: bike_models[:cannondale_trail].id, customer_id: customers[:tomas].id),
    antonia_bignine: Bike.create!(serial_number: "MB-2021-0342", bike_model_id: bike_models[:merida_big_nine].id, customer_id: customers[:antonia].id),
    vicente_nirone: Bike.create!(serial_number: "BV-2024-0056", bike_model_id: bike_models[:bianchi_nirone].id, customer_id: customers[:vicente].id),
    isidora_domane: Bike.create!(serial_number: "TD-2022-0789", bike_model_id: bike_models[:trek_domane].id, customer_id: customers[:isidora].id),
    maximiliano_talon: Bike.create!(serial_number: "GT-2023-0123", bike_model_id: bike_models[:giant_talon].id, customer_id: customers[:maximiliano].id),
    josefa_sirrus: Bike.create!(serial_number: "SS-2024-0067", bike_model_id: bike_models[:specialized_sirrus].id, customer_id: customers[:josefa].id),
    agustin_marlin2: Bike.create!(serial_number: "TM-2024-0114", bike_model_id: bike_models[:trek_marlin].id, customer_id: customers[:agustin].id),
    constanza_aspect2: Bike.create!(serial_number: "SA-2022-0009", bike_model_id: bike_models[:scott_aspect].id, customer_id: customers[:constanza].id),
    diego_nirone: Bike.create!(serial_number: "BV-2023-0301", bike_model_id: bike_models[:bianchi_nirone].id, customer_id: customers[:diego].id)
  }

  # --- Repairs and the services on each one ---------------------------------------------------------------
  #
  # add_services charges each service at its current list price unless an override is given —
  # the override is how a repair ends up charging less than what's on the wall today.

  add_services = lambda do |repair, entries|
    entries.each do |service_name, override_price|
      service = services.fetch(service_name)
      RepairService.create!(
        repair_id: repair.id,
        service_id: service.id,
        charged_price: override_price || service.price
      )
    end
  end

  # R1 — just walked in today, nothing decided about who'll take it yet.
  r1 = Repair.create!(
    bike_id: bikes[:javiera_marlin].id, customer_id: customers[:javiera].id, mechanic_id: nil,
    state: "received", received_at: 1.day.ago, promised_on: 4.days.from_now.to_date
  )
  add_services.call(r1, [ [ "Flat tire repair", nil ] ])

  # R2 — the same bike's earlier visit, fully wrapped up. Together with R1: one bike, two repairs,
  # different dates.
  r2_charges = { "Chain replacement" => nil, "Chain cleaning and lubrication" => nil }
  r2 = Repair.create!(
    bike_id: bikes[:javiera_marlin].id, customer_id: customers[:javiera].id, mechanic_id: mechanics[:fuentes].id,
    state: "collected", received_at: 2.months.ago, promised_on: (2.months.ago + 5.days).to_date,
    quoted_at: 2.months.ago + 1.day,
    quoted_amount: r2_charges.sum { |name, _| services.fetch(name).price },
    quote_response: "approved", responded_at: 2.months.ago + 2.days,
    finished_at: 2.months.ago + 6.days, collected_at: 2.months.ago + 7.days
  )
  add_services.call(r2, r2_charges.to_a)

  # R3 — the mechanic has looked at it and written down what's wrong; no price yet.
  r3 = Repair.create!(
    bike_id: bikes[:javiera_escape].id, customer_id: customers[:javiera].id, mechanic_id: mechanics[:rojas].id,
    state: "diagnosed", received_at: 3.days.ago, promised_on: 3.days.from_now.to_date
  )
  add_services.call(r3, [ [ "Brake adjustment", nil ] ])

  # R4 — quoted, waiting on the customer's answer.
  r4_charges = { "Wheel truing" => nil, "Hub adjustment" => nil }
  r4 = Repair.create!(
    bike_id: bikes[:cristobal_rockhopper].id, customer_id: customers[:cristobal].id, mechanic_id: mechanics[:soto].id,
    state: "quoted", received_at: 5.days.ago, promised_on: 2.days.from_now.to_date,
    quoted_at: 1.day.ago, quoted_amount: r4_charges.sum { |name, _| services.fetch(name).price },
    quote_response: nil, responded_at: nil
  )
  add_services.call(r4, r4_charges.to_a)

  # R5 — quoted and approved, work hasn't started.
  r5_charges = { "Basic tune-up" => nil }
  r5 = Repair.create!(
    bike_id: bikes[:florencia_aspect].id, customer_id: customers[:florencia].id, mechanic_id: mechanics[:fuentes].id,
    state: "approved", received_at: 6.days.ago, promised_on: 1.day.from_now.to_date,
    quoted_at: 4.days.ago, quoted_amount: r5_charges.sum { |name, _| services.fetch(name).price },
    quote_response: "approved", responded_at: 3.days.ago
  )
  add_services.call(r5, r5_charges.to_a)

  # R6 — the customer heard the price and said no. Bike is still here, untouched.
  r6_charges = { "Brake pad replacement" => nil, "Brake cable replacement" => nil }
  r6 = Repair.create!(
    bike_id: bikes[:tomas_trail].id, customer_id: customers[:tomas].id, mechanic_id: mechanics[:rojas].id,
    state: "declined", received_at: 10.days.ago, promised_on: (10.days.ago + 5.days).to_date,
    quoted_at: 8.days.ago, quoted_amount: r6_charges.sum { |name, _| services.fetch(name).price },
    quote_response: "declined", responded_at: 7.days.ago
  )
  add_services.call(r6, r6_charges.to_a)

  # R7 — obvious and cheap, started the same day it came in, no quote needed.
  r7 = Repair.create!(
    bike_id: bikes[:antonia_bignine].id, customer_id: customers[:antonia].id, mechanic_id: mechanics[:soto].id,
    state: "in_progress", received_at: 1.day.ago, promised_on: 1.day.from_now.to_date
  )
  add_services.call(r7, [ [ "Flat tire repair", nil ], [ "Chain cleaning and lubrication", nil ] ])

  # R8 — went through a quote and an approval before work started.
  r8_charges = { "Full tune-up" => nil }
  r8 = Repair.create!(
    bike_id: bikes[:vicente_nirone].id, customer_id: customers[:vicente].id, mechanic_id: mechanics[:fuentes].id,
    state: "in_progress", received_at: 4.days.ago, promised_on: 2.days.from_now.to_date,
    quoted_at: 3.days.ago, quoted_amount: r8_charges.sum { |name, _| services.fetch(name).price },
    quote_response: "approved", responded_at: 2.days.ago
  )
  add_services.call(r8, r8_charges.to_a)

  # R9 — finished, but the promised day has already passed and nobody's picked it up.
  r9_charges = { "Full tune-up" => nil, "Brake pad replacement" => nil }
  r9 = Repair.create!(
    bike_id: bikes[:isidora_domane].id, customer_id: customers[:isidora].id, mechanic_id: mechanics[:rojas].id,
    state: "finished", received_at: 3.weeks.ago, promised_on: 1.week.ago.to_date,
    quoted_at: 18.days.ago, quoted_amount: r9_charges.sum { |name, _| services.fetch(name).price },
    quote_response: "approved", responded_at: 17.days.ago, finished_at: 4.days.ago
  )
  add_services.call(r9, r9_charges.to_a)

  # R10 — finished early, well before the promised day; just waiting on pickup.
  r10 = Repair.create!(
    bike_id: bikes[:maximiliano_talon].id, customer_id: customers[:maximiliano].id, mechanic_id: mechanics[:soto].id,
    state: "finished", received_at: 6.days.ago, promised_on: 1.day.from_now.to_date, finished_at: 1.day.ago
  )
  add_services.call(r10, [ [ "Safety inspection", nil ] ])

  # R11 — came in and went out the same day.
  same_day = 10.days.ago.to_date
  r11 = Repair.create!(
    bike_id: bikes[:josefa_sirrus].id, customer_id: customers[:josefa].id, mechanic_id: mechanics[:fuentes].id,
    state: "collected", received_at: same_day.to_time + 9.hours, promised_on: same_day,
    finished_at: same_day.to_time + 11.hours, collected_at: same_day.to_time + 17.hours
  )
  add_services.call(r11, [ [ "Flat tire repair", nil ] ])

  # R12 — the second Trek Marlin's only repair: full path from quote to pickup.
  r12_charges = { "Cassette replacement" => nil, "Gear adjustment" => nil }
  r12 = Repair.create!(
    bike_id: bikes[:agustin_marlin2].id, customer_id: customers[:agustin].id, mechanic_id: mechanics[:rojas].id,
    state: "collected", received_at: 3.weeks.ago, promised_on: 16.days.ago.to_date,
    quoted_at: 20.days.ago, quoted_amount: r12_charges.sum { |name, _| services.fetch(name).price },
    quote_response: "approved", responded_at: 19.days.ago,
    finished_at: 15.days.ago, collected_at: 14.days.ago
  )
  add_services.call(r12, r12_charges.to_a)

  # R13 — just walked in today.
  r13 = Repair.create!(
    bike_id: bikes[:constanza_aspect2].id, customer_id: customers[:constanza].id, mechanic_id: nil,
    state: "received", received_at: Time.current, promised_on: 5.days.from_now.to_date
  )
  add_services.call(r13, [ [ "Tire replacement", nil ] ])

  # R14 — from well before last January. The list price for a full tune-up has gone up since;
  # this repair still shows what was actually charged at the time.
  historical_date = 14.months.ago
  r14_charge = { "Full tune-up" => 48_000 } # list price today is 55_000
  r14 = Repair.create!(
    bike_id: bikes[:javiera_escape].id, customer_id: customers[:javiera].id, mechanic_id: mechanics[:soto].id,
    state: "collected", received_at: historical_date, promised_on: (historical_date + 5.days).to_date,
    quoted_at: historical_date + 1.day, quoted_amount: r14_charge.values.first,
    quote_response: "approved", responded_at: historical_date + 2.days,
    finished_at: historical_date + 6.days, collected_at: historical_date + 7.days
  )
  add_services.call(r14, r14_charge.to_a)

  # R15 — a loyal customer, charged less than the list price on the spot; no formal quote for a
  # job this small.
  r15 = Repair.create!(
    bike_id: bikes[:florencia_aspect].id, customer_id: customers[:florencia].id, mechanic_id: mechanics[:fuentes].id,
    state: "collected", received_at: 1.month.ago, promised_on: (1.month.ago + 3.days).to_date,
    finished_at: 1.month.ago + 2.days, collected_at: 1.month.ago + 2.days
  )
  add_services.call(r15, [ [ "Brake adjustment", 9_000 ] ]) # list price is 12_000

  # R16 — a second repair for Maximiliano's bike, currently being worked on.
  r16_charges = { "Wheel truing" => nil, "Spoke replacement" => nil, "Hub adjustment" => nil }
  r16 = Repair.create!(
    bike_id: bikes[:maximiliano_talon].id, customer_id: customers[:maximiliano].id, mechanic_id: mechanics[:soto].id,
    state: "in_progress", received_at: 2.days.ago, promised_on: 3.days.from_now.to_date,
    quoted_at: 1.day.ago, quoted_amount: r16_charges.sum { |name, _| services.fetch(name).price },
    quote_response: "approved", responded_at: 12.hours.ago
  )
  add_services.call(r16, r16_charges.to_a)

  # --- Invoices ---------------------------------------------------------------
  #
  # One per collected repair, issued the moment the bike was handed back.

  { r2 => "INV-0001", r11 => "INV-0002", r12 => "INV-0003", r14 => "INV-0004", r15 => "INV-0005" }.each do |repair, number|
    Invoice.create!(repair_id: repair.id, number: number, issued_at: repair.collected_at)
  end
end

puts "Seeded: #{Customer.count} customers, #{BikeModel.count} bike models, #{Bike.count} bikes, " \
     "#{Mechanic.count} staff, #{Service.count} services, #{Repair.count} repairs, " \
     "#{RepairService.count} repair services, #{Invoice.count} invoices."
