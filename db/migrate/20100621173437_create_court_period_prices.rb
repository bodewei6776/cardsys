class CreateCourtPeriodPrices < ActiveRecord::Migration
  def self.up
    create_table :court_period_prices , :options => ' DEFAULT CHARSET=utf8' do |t|
      t.integer :court_id, :null => false
      t.integer :period_price_id, :null => false
      t.decimal :court_price, :null => false, :default => 0, :precision => 10, :scale => 2
      t.text :description
      t.integer :status, :null => false, :default => 0
      t.integer :catena_id, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :court_period_prices
  end
end
