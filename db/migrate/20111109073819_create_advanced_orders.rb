class CreateAdvancedOrders < ActiveRecord::Migration
  def self.up
    create_table :advanced_orders do |t|
      t.integer :wday
      t.date :start_date
      t.date :end_date
      t.integer :start_hour
      t.integer :end_hour
      t.integer :court_id

      t.timestamps
    end
  end

  def self.down
    drop_table :advanced_orders
  end
end
