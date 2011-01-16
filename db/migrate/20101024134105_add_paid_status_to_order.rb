class AddPaidStatusToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :paid_stauts, :integer,:null => false,:default => 0
    add_column :orders, :amount,      :decimal,:null => false,:default => 0
    add_column :order_items, :paid_status, :integer,:null => false,:default => 0
  end

  def self.down
    remove_column :order_items, :column_name
    remove_column :orders, :amount
    remove_column :orders, :paid_stauts
  end
end
