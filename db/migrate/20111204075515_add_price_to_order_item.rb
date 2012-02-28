# -*- encoding : utf-8 -*-
class AddPriceToOrderItem < ActiveRecord::Migration
  def self.up
    add_column :order_items, :price, :string
  end

  def self.down
    remove_column :order_items, :price
  end
end
