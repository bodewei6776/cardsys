class AddCountamountToBalance < ActiveRecord::Migration
  def self.up
    add_column :balances,:count_amount,:integer,:null => false,:default => 0
  end

  def self.down
    drop_column :balances,:count_amount
  end
end
