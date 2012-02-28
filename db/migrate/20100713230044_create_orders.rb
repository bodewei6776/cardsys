# -*- encoding : utf-8 -*-
class CreateOrders < ActiveRecord::Migration
  
  def self.up
    create_table :orders  do |t|
      t.integer   :member_card_id
      t.integer   :member_id
      t.integer   :non_member_id
      t.string    :memo
      t.string    :type
      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
  
end
