class AddRandomRentUserName < ActiveRecord::Migration

  def self.up
    add_column :rents,:random_member_name,:string
  end

  def self.down
    remove_column :rents,:random_member_name
  end
end
