class AddUserIdToOrderAndOrderItem < ActiveRecord::Migration
  def self.up
    add_column :orders,:user_id,:integer
    add_column :order_items,:user_id,:integer
  end

  def self.down
    remove_column :order_items,:user_id
    remove_column :orders,:user_id
  end
end
