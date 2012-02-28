# -*- encoding : utf-8 -*-
class AddIsMemberToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :is_member, :boolean
  end

  def self.down
    remove_column :orders, :is_member
  end
end
