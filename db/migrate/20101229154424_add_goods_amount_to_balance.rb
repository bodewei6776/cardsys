class AddGoodsAmountToBalance < ActiveRecord::Migration
  
  def self.up
    add_column :balances, :goods_amount, :decimal
    rename_column :balances, :amount,             :book_record_amount
    rename_column :balances, :realy_amount,       :book_record_realy_amount
    add_column    :balances, :goods_realy_amount, :decimal,:default => 0
  end

  def self.down
    remove_column :balances,  :goods_amount
    rename_column :balances,  :book_record_amount, :amount
    rename_column :balances,  :book_record_realy_amount, :realy_amount
    remove_column :balances,  :goods_realy_amount
  end
  
end