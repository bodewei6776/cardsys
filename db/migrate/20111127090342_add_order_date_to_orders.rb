class AddOrderDateToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :order_date, :date
  end

  def self.down
    remove_column :orders, :order_date
  end
end
