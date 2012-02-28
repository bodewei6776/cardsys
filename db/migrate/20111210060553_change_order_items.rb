# -*- encoding : utf-8 -*-
class ChangeOrderItems < ActiveRecord::Migration
  def self.up
    remove_column :order_items, :price
    add_column :order_items, :unit_money_price, :decimal, :scale => 2, :precision => 10
    add_column :order_items, :total_money_price, :decimal, :scale => 2, :precision => 10
    add_column :order_items, :total_count, :integer
  end

  def self.down
    add_column :order_items, :price, :string
    remove_column :order_items, :unit_money_price
    remove_column :order_items, :total_money_price
    remove_column :order_items, :total_count
  end
end
