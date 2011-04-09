class AddUserIdToBalance < ActiveRecord::Migration
  def self.up
    add_column :balances,:user_id,:integer
  end

  def self.down
    remove_column :balances,:user_id
  end
end
