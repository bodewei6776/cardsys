class CreateGoods < ActiveRecord::Migration
  def self.up
    create_table :goods , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string :name, :null => false, :default => ''
      t.integer :good_type, :null => false #common_resource_detail_id
      t.decimal :purchasing_price, :null => false, :default => 0, :precision => 10, :scale => 2
      t.decimal :price, :null => false, :default => 0, :precision => 10, :scale => 2
      t.integer :status, :null => false, :default => 0
      t.integer :catena_id, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :goods
  end
end
