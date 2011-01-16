class CreateOrders < ActiveRecord::Migration
  
  def self.up
    create_table :orders , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer   :card_id,:null => false,:default => 0
      t.integer   :member_id,:book_record_id,:null => false,:default => 0
      t.string    :memo,:null => false,:default => ''
      t.datetime  :order_time,:null => false
      t.string    :member_name,:null => false,:default => '',:limit => 32
      t.integer   :catena_id,:null => false,:default => 0
    end
  end

  def self.down
    drop_table :orders
  end
  
end
