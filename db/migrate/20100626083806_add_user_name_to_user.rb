class AddUserNameToUser < ActiveRecord::Migration
  def self.up
#    add_column  :users,:user_name,:string,:null => false,:default => '',:limit => 24
  end

  def self.down
#    remove_column :users,:user_name
  end
end
