class RemovePaidStatusFromOrderItemAndOrder < ActiveRecord::Migration
  def self.up
    remove_column :orders, :paid_stauts
    remove_column :order_items, :paid_status
  end

  def self.down
    add_column :order_items, :paid_status, :integer
    add_column :orders, :paid_stauts, :integer
  end
end
