class ChangeOrderItemsItemType < ActiveRecord::Migration
  def self.up
    OrderItem.update_all("item_type='BookRecord'", "item_type = '1'")
    OrderItem.update_all("item_type='BookRecord'", "item_type = '0'")
    OrderItem.update_all("item_type='Coach'", "item_type = '2'")
    OrderItem.update_all("item_type='Good'", "item_type = '3'")
  end

  def self.down
    OrderItem.update_all("item_type='1'", "item_type = 'BookRecord'")
    OrderItem.update_all("item_type='2'", "item_type = 'Coach'")
    OrderItem.update_all("item_type='3'", "item_type = 'Good'")
  end
end
