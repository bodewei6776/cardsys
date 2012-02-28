# -*- encoding : utf-8 -*-
class AddDiscountToOrderItems < ActiveRecord::Migration
  def self.up
    add_column :order_items, :discount, :decimal, :scale => 1, :precision => 8
    add_column :order_items, :price_after_discount, :decimal, :scale => 2, :precision => 8
    add_column :order_items, :balance_id, :integer
  end

  def self.down
    remove_column :order_items, :discount
    remove_column :order_items, :price_after_discount
    remove_column :order_items, :balance_id
  end
end
