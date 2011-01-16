class CreatePeriodPrices < ActiveRecord::Migration

  def self.up
    create_table :period_prices , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string :name, :null => false
      t.integer :start_time, :null => false, :default => 7
      t.integer :end_time, :null => false, :default => 7
      t.decimal :price, :null => false, :default => 0, :precision => 10, :scale => 2
      t.integer :period_type, :null => false, :default => 0 #common_resource_detail_id season 0:winter, 1:summer, 2:vacation
      t.integer :catena_id, :null => false, :default => 0 #
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :period_prices
  end
  
end
