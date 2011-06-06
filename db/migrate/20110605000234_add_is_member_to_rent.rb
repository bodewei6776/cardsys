class AddIsMemberToRent < ActiveRecord::Migration
  def self.up
    add_column :rents,:is_member,:boolean
  end

  def self.down
    remove_column :rents,:is_member
  end
end
