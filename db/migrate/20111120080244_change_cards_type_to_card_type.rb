class ChangeCardsTypeToCardType < ActiveRecord::Migration
  def self.up
    rename_column :cards, :type, :card_type
  end

  def self.down
    rename_column :cards, :card_type, :type
  end
end
