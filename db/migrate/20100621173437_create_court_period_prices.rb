# -*- encoding : utf-8 -*-
class CreateCourtPeriodPrices < ActiveRecord::Migration
  def self.up
    create_table :court_period_prices  do |t|
      t.integer :court_id
      t.integer :period_price_id
      t.decimal :court_price, :default => 0, :precision => 10, :scale => 2
      t.text    :description
      t.timestamps
    end
  end

  def self.down
    drop_table :court_period_prices
  end
end
