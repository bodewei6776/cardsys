# -*- encoding : utf-8 -*-
class AddColumnBalancedToOrderItems < ActiveRecord::Migration
  def self.up
    add_column :order_items, :balanced, :boolean
  end

  def self.down
    remove_column :order_items, :balanced
  end
end
