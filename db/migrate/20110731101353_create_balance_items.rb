class CreateBalanceItems < ActiveRecord::Migration
  def self.up
    create_table :balance_items do |t|
      t.integer :order_id
      t.integer :order_item_id
      t.integer :balance_id
      t.integer :price
      t.float :discount_rate
      t.string :reason

      t.timestamps
    end
  end

  def self.down
    drop_table :balance_items
  end
end
