# -*- encoding : utf-8 -*-
class CreateBalances < ActiveRecord::Migration
  
  def self.up
    create_table :balances  do |t|
      t.integer   :order_id
      t.decimal   :price ,:final_price, :precision => 10, :scale => 2 
      t.string    :change_note
      t.string    :balance_way,
      t.timestamps
    end
  end

  def self.down
    drop_table :balances
  end
  
end
