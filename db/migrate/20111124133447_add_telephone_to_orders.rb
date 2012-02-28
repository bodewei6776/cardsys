# -*- encoding : utf-8 -*-
class AddTelephoneToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :telephone, :string
  end

  def self.down
    remove_column :orders, :telephone
  end
end
