class ChangeColumnOrBalanceAndBalanceItem < ActiveRecord::Migration
  def self.up
    remove_column :balances, :book_record_amount
    remove_column :balances, :book_record_realy_amount
    remove_column :balances, :catena_id
    remove_column :balances, :member_type
    remove_column :balances, :goods_balance_type
    remove_column :balances, :goods_amount
    remove_column :balances, :goods_realy_amount
    remove_column :balances, :goods_member_card_id
    remove_column :balances, :book_reocrd_member_card_id

    add_column :balances, :amount, :integer
    add_column :balances, :real_amount, :integer

    add_column :balance_items, :real_price, :integer
  end

  def self.down
    remove_column :balance_items, :real_price
    remove_column :balances, :real_amount
    remove_column :balances, :amount
    add_column :balances, :book_reocrd_member_card_id, :integer
    add_column :balances, :goods_member_card_id, :integer 
    add_column :balances, :goods_realy_amount, :integer 
    add_column :balances, :goods_amount, :integer 
    add_column :balances, :goods_balance_type, :integer 
    add_column :balances, :member_type, :integer 
    add_column :balances, :catena_id, :integer 
    add_column :balances, :book_record_realy_amount, :integer 
    add_column :balances, :book_record_amount, :integer 
  end
end
