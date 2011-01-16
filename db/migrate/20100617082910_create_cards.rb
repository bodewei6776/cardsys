class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards  , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.string  :name, :null => false, :default => ''
      t.integer :card_type, :null => false, :default => 1#common_resource_detail_id
      t.string  :card_prefix, :null => false, :default => ''
      t.integer :expired, :null => false, :default => 12 #month
      t.integer :consume_type, :default => 0#可消费的类型
      t.integer :is_shared, :default => 0#是否有授权人
      t.integer :shared_amount, :default => 0#授权人的数量
      t.integer :sale_amount, :default => 0#
      t.integer :catena_id, :null => false, :default => 0 #
      t.string  :description, :null => false
      t.integer :counts, :default => 0#默认记次数
      t.decimal :balance, :default => 0, :precision => 10, :scale => 2#默认储值数目
      t.integer :status, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :cards
  end
end
