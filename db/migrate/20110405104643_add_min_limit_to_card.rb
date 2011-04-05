class AddMinLimitToCard < ActiveRecord::Migration
  def self.up
    add_column :cards,:min_amount,:integer
    add_column :cards,:min_count,:integer
    add_column :cards,:min_time,:integer
  end

  def self.down
    remove_column :cards,:min_amount
    remove_column :cards,:min_time
    remove_column :cards,:min_count
  end
end
