class AddRentStateToRent < ActiveRecord::Migration
  def change
    add_column :rents, :rent_state, :string
  end
end
