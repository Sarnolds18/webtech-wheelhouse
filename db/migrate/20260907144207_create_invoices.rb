class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.bigint :repair_id, null: false
      t.string :number, null: false
      t.datetime :issued_at, null: false

      t.timestamps
    end

    add_index :invoices, :repair_id, unique: true
    add_index :invoices, :number, unique: true
  end
end
