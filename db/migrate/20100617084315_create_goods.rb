class CreateGoods < ActiveRecord::Migration
  def self.up
    create_table :goods do |t|
      t.string :name
      t.string :name_pinyin
      t.string :pinyin_abbr
      t.integer :good_type #common_resource_detail_id
      t.decimal :purchasing_price, :precision => 10, :scale => 2
      t.decimal :price, :default => 0, :precision => 10, :scale => 2
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :goods
  end
end
