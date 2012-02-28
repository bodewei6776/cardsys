# -*- encoding : utf-8 -*-
class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.string  :name
      t.string  :type
      t.string  :card_prefix
      t.integer :expired, :default => 12 #month
      t.string  :consume_type #可消费的类型
      t.boolean :shared, :default => 0#是否有授权人
      t.integer :max_shared_count, :default => 0#授权人的数量
      t.integer :total_sold_amount, :default => 0#
      t.string  :description
      t.decimal :balance, :default => 0, :precision => 10, :scale => 2#默认储值数目
      t.string  :state
      t.timestamps
    end
  end

  def self.down
    drop_table :cards
  end
end
