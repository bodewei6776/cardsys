# -*- encoding : utf-8 -*-
class CreateCardPeriodPrices < ActiveRecord::Migration
  def self.up
    create_table :card_period_prices do |t|
      t.integer :card_id
      t.integer :period_price_id
      t.decimal :card_price, :default => 0, :precision => 10, :scale => 2
      t.text    :description
      t.timestamps
    end
  end

  def self.down
    drop_table :card_period_prices
  end
end
