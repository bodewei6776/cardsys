class AddColumnToMemberCardGranter < ActiveRecord::Migration
  def self.up
    add_column :member_card_granters, :member_id, :integer, :null => false
  end

  def self.down
    remove_column :member_card_granters, :member_id
  end
end
