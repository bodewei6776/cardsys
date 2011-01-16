class CreateAdvancedOrders < ActiveRecord::Migration
  def self.up
    create_table :advanced_orders , :options => ' DEFAULT CHARSET=utf8' do |t|      
      t.integer   :court_id,:null => false,:default => 0
      t.date      :start_date,:end_date,:null => false
      t.integer   :wday,:null => false,:default => 0,:limit => 1
      t.integer   :start_hour,:end_hour,:null => false,:limit => 1
      t.integer   :member_card_id,:member_id,:null => false,:default => 0
      t.timestamps
      
    end
  end

  def self.down
    drop_table :advanced_orders
  end
end
