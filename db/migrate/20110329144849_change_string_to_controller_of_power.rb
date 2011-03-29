class ChangeStringToControllerOfPower < ActiveRecord::Migration
  def self.up
    rename_column :powers,:string,:controller
  end

  def self.down
    rename_column :powers,:controller,:string
  end
end
