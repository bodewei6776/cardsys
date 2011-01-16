class DropColumnToMember < ActiveRecord::Migration
  def self.up
#    remove_column :members, :integer
    remove_column :members, :is_granter
  end

  def self.down
  end
end
