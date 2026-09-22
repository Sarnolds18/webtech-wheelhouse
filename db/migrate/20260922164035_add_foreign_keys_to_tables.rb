class AddForeignKeysToTables < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :bikes, :bike_models
    add_foreign_key :bikes, :customers
    add_foreign_key :repairs, :bikes
    add_foreign_key :repairs, :customers
    add_foreign_key :repairs, :mechanics
    add_foreign_key :repair_services, :repairs
    add_foreign_key :repair_services, :services
    add_foreign_key :invoices, :repairs
  end
end
