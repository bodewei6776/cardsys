# -*- encoding : utf-8 -*-
class ChangeMemberCardIdToMembersCardId < ActiveRecord::Migration
  def self.up
    rename_column :orders, :member_card_id, :members_card_id
  end

  def self.down
    rename_column :orders, :members_card_id, :member_card_id
  end
end
