class ChangeRelationBetweenOrderAndNonMember < ActiveRecord::Migration
  def self.up
    remove_column :orders, :non_member_id
    add_column :non_members, :order_id, :integer
  end

  def self.down
    add_column :orders, :non_member_id, :integer
    remove_column :non_members, :order_id
  end
end
