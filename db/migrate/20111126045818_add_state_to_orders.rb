# -*- encoding : utf-8 -*-
class AddStateToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :state, :string
  end

  def self.down
    remove_column :orders, :state
  end
end
