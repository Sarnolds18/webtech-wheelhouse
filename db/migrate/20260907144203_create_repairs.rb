class CreateRepairs < ActiveRecord::Migration[8.0]
  def change
    create_table :repairs do |t|
      t.bigint :bike_id, null: false
      t.bigint :customer_id, null: false
      t.bigint :mechanic_id
      t.string :state, null: false, default: "received"
      t.datetime :received_at, null: false
      t.date :promised_on, null: false
      t.datetime :quoted_at
      t.decimal :quoted_amount, precision: 10, scale: 2
      t.string :quote_response
      t.datetime :responded_at
      t.datetime :finished_at
      t.datetime :collected_at

      t.timestamps
    end

    add_index :repairs, :bike_id
    add_index :repairs, :customer_id
    add_index :repairs, :mechanic_id
  end
end
