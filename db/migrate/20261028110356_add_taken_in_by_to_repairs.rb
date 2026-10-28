class AddTakenInByToRepairs < ActiveRecord::Migration[8.1]
  def change
    # The account that took the repair in. NULL for the repairs that existed before accounts did.
    add_reference :repairs, :taken_in_by, foreign_key: { to_table: :users }
  end
end
