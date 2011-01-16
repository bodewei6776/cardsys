class AddMemberCardIdToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :member_card_id, :integer, :null => false
  end

  def self.down
    remove_column :orders,:member_card_id
  end
end
