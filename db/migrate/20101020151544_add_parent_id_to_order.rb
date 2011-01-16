class AddParentIdToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :parent_id, :integer,:null => false,:defalt => 0
  end

  def self.down
    remove_column :orders, :parent_id
  end
end
