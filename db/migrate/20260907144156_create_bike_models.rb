class CreateBikeModels < ActiveRecord::Migration[8.0]
  def change
    create_table :bike_models do |t|
      t.string :brand, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
