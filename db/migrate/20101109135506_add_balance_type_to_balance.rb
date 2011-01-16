class AddBalanceTypeToBalance < ActiveRecord::Migration
  def self.up
    add_column :balances, :goods_balance_type, :integer,:null => false,:default => 0,:limit => 1
    add_column :balances, :status, :integer,:null => false,:default => 0,:limit => 1
    remove_column :balances, :order_type
  end

  def self.down
    remove_column :balances, :status
    remove_column :balances, :goods_balance_type
  end
end
