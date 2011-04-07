class AddStateToMemberCardGranter < ActiveRecord::Migration
  def self.up
    add_column :member_card_granters,:state,:string
  end

  def self.down
    remove_column :member_card_granters,:state
  end
end
