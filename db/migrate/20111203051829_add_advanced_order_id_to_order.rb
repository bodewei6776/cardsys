class AddAdvancedOrderIdToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :advanced_order_id, :integer
  end

  def self.down
    remove_column :orders, :advanced_order_id
  end
end
