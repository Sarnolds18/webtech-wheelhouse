class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :category

      t.timestamps
    end

    add_index :services, :name, unique: true
  end
end
