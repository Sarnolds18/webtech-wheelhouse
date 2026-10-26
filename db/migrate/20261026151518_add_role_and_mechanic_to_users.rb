class AddRoleAndMechanicToUsers < ActiveRecord::Migration[8.1]
  def change
    # The default is the role with the fewest permissions (docs/decisions.md).
    add_column :users, :role, :string, null: false, default: "mechanic"

    # An account may belong to one member of the staff, and a member of the staff has at most one
    # account: the unique index refuses a second one. NULL is an account with no member of the staff.
    add_reference :users, :mechanic, foreign_key: true, index: { unique: true }

    # The model writes the address in lowercase, but the database refuses a duplicate on its own as well:
    # Ana@Wheelhouse.cl and ana@wheelhouse.cl are the same account.
    remove_index :users, :email_address, unique: true
    add_index :users, "lower(email_address)", unique: true, name: "index_users_on_lower_email_address"
  end
end
