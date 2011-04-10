class DropCatenaIdFromPower < ActiveRecord::Migration
  def self.up
    remove_column :powers,:catena_id
    remove_column :user_powers,:catena_id
    remove_column :department_powers,:catena_id
  end

  def self.down
    add_column :powers,:catena_id,:integer
    add_column :user_powers,:catena_id,:integer
    add_column :department_powers,:catena_id,:integer
  end
end
