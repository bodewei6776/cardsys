# -*- encoding : utf-8 -*-
class CreateOrderItems < ActiveRecord::Migration

  def self.up
    create_table :order_items  do |t|
      t.integer    :order_id
      t.integer    :item_id
      t.string     :item_type
      t.integer    :quantity
    end
  end

  def self.down
    drop_table :order_items
  end
  
end
