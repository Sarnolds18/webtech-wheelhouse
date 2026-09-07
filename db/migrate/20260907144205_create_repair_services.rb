class CreateRepairServices < ActiveRecord::Migration[8.0]
  def change
    create_table :repair_services do |t|
      t.bigint :repair_id, null: false
      t.bigint :service_id, null: false
      t.decimal :charged_price, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :repair_services, :repair_id
    add_index :repair_services, :service_id
  end
end
