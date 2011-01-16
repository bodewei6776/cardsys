class AddBuyCountToGoods < ActiveRecord::Migration
  
  def self.up
    add_column :goods, :sale_count, :integer,:null => false,:default => 0
  end

  def self.down
    remove_column :goods, :sale_count
  end
  
end
