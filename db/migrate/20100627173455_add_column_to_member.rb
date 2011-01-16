class AddColumnToMember < ActiveRecord::Migration
  def self.up
    add_column :members, :is_member, :integer, :null => false, :default => 1
    add_column :members, :is_granter, :integer, :null => false
  end

  def self.down
    remove_column :members, :is_member
    remove_column :members, :is_granter
  end
end
