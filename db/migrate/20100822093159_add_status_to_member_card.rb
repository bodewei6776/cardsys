class AddStatusToMemberCard < ActiveRecord::Migration
  def self.up
    add_column :member_cards, :status, :integer, :default => 0
  end

  def self.down
    remove_column :member_card, :status
  end
end
