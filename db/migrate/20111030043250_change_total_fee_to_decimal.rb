class ChangeTotalFeeToDecimal < ActiveRecord::Migration
  def self.up
    change_column :rents, :total_fee, :decimal, :scale => 2, :precision => 8
  end

  def self.down
    change_column :rents, :total_fee,  :integer
  end
end
