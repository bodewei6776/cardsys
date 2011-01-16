class CreateCardPeriodPrices < ActiveRecord::Migration
  def self.up
    create_table :card_period_prices , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer :card_id, :null => false, :default => 1
      t.integer :period_price_id, :null => false, :default => 1
      t.decimal :card_price, :null => false, :default => 0, :precision => 10, :scale => 2
      t.text    :description
      t.integer :catena_id, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :card_period_prices
  end
end
