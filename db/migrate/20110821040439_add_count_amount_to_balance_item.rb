class AddCountAmountToBalanceItem < ActiveRecord::Migration
  def self.up
    add_column :balance_items, :count_amount, :integer
  end

  def self.down
    remove_column :balance_items, :count_amount
  end
end
