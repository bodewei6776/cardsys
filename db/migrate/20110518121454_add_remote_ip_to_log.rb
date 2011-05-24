class AddRemoteIpToLog < ActiveRecord::Migration
  def self.up
    add_column :logs,:remote_ip,:string
  end

  def self.down
 #   remove_column :logs,:remote_ip
  end
end
