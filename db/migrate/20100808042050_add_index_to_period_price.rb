class AddIndexToPeriodPrice < ActiveRecord::Migration
  def self.up
    add_index :period_prices, [:start_time, :end_time, :period_type], :unique => true
  end

  def self.down
  end
end
