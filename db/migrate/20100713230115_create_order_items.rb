class CreateOrderItems < ActiveRecord::Migration

  def self.up
    create_table :order_items , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer    :order_id, :null => false,:default => 0
      t.integer    :item_id,  :null => false,:default => 0
      t.integer    :item_type,:null => false,:default => 0,:limit => 1
      t.integer    :quantity, :null => false,:default => 0,:limit => 2
      t.integer    :price,:null => false,:default => 0
      t.datetime   :order_time,:null => false
      t.integer    :catena_id,:null => false,:default => 0
    end
  end

  def self.down
    drop_table :order_items
  end
  
end
