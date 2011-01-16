class AddStartTimeToOrderItem < ActiveRecord::Migration

  def self.up
    add_column  :order_items,:start_hour,:integer,:null => false,:default => 0,:limit => 1
    add_column  :order_items,:end_hour,:integer,:null => false,:default => 0,:limit => 1
    add_column  :order_items,:order_date,:date,:null => false
  end

  def self.down
    drop_column :order_items,:start_hour
    drop_column :order_items,:end_hour
    drop_column :order_items,:order_date
  end

end
