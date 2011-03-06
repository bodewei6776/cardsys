class AddCardIdToBalance < ActiveRecord::Migration

  def self.up
    add_column :balances,:goods_member_card_id,:integer,:null => false,:default => 0
    add_column :balances,:book_reocrd_member_card_id,:integer,:null => false,:default => 0
    add_column :balances,:member_id,:integer,:null => false,:default => 0
  end

  def self.down
    drop_column :balances,:goods_member_card_id
    drop_column :balances,:book_reocrd_member_card_id
    drop_column :balances,:member_id
  end

end
