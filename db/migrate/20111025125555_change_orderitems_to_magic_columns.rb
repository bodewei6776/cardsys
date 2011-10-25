class ChangeOrderitemsToMagicColumns < ActiveRecord::Migration
  def self.up
    remove_column :order_items, :order_time
    remove_column :order_items, :catena_id
    remove_column :order_items, :start_hour
    remove_column :order_items, :end_hour
    remove_column :order_items, :order_date
    remove_column :order_items, :user_id
    change_column :order_items, :price, :decimal, :scale => 2, :precision => 10 
  end

  def self.down
    change_column :order_itmes, :price, :integer
    add_column :order_items, :user_id, :integer
    add_column :order_items, :order_date, :date
    add_column :order_items, :end_hour, :integer
    add_column :order_items, :start_hour, :integer
    add_column :order_items, :catena_id, :integer
    add_column :order_items, :order_time, :datetime
  end
end
