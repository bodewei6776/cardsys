class AddMemberNameToRent < ActiveRecord::Migration
  def self.up
    add_column :rents,:member_name,:string
  end

  def self.down
    remove_column :rents,:member_name
  end
end
