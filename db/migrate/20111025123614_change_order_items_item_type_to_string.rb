class ChangeOrderItemsItemTypeToString < ActiveRecord::Migration
  def self.up
    change_column :order_items, :item_type, :string
  end

  def self.down
    change_column :order_items, :item_type, :integer
  end
end
