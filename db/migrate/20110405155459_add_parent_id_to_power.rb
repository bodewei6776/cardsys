class AddParentIdToPower < ActiveRecord::Migration
  def self.up
    add_column :powers,:parent_id,:integer
  end

  def self.down
    remove_column :powers,:parent_id
  end
end
