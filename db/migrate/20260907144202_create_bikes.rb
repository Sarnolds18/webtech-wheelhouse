class CreateBikes < ActiveRecord::Migration[8.0]
  def change
    create_table :bikes do |t|
      t.string :serial_number, null: false
      t.bigint :bike_model_id, null: false
      t.bigint :customer_id, null: false

      t.timestamps
    end

    add_index :bikes, :serial_number, unique: true
    add_index :bikes, :bike_model_id
    add_index :bikes, :customer_id
  end
end
