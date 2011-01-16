class AddColumnToGoods < ActiveRecord::Migration
  def self.up
    add_column :goods, :count_total_now, :integer, :null => false,:default => 0
    add_column :goods, :count_back_stock, :integer, :null => false,:default => 0
    add_column :goods, :count_front_stock, :integer, :null => false,:default => 0

    add_column :goods, :count_back_stock_in, :integer,:default => 0
    add_column :goods, :count_back_stock_out, :integer,:default => 0
    add_column :goods, :count_front_stock_in, :integer,:default => 0
    add_column :goods, :count_front_stock_out, :integer,:default => 0

    add_column :goods, :good_source, :integer,:default => 0
  end

  def self.down
    remove_column :goods, :count_total_now
    remove_column :goods, :count_back_stock
    remove_column :goods, :count_front_stock

    remove_column :goods, :count_back_stock_in
    remove_column :goods, :count_back_stock_out
    remove_column :goods, :count_front_stock_in
    remove_column :goods, :count_front_stock_out

    remove_column :goods, :good_source
  end
end
