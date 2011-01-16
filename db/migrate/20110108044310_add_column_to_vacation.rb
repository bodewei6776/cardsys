class AddColumnToVacation < ActiveRecord::Migration
  def self.up
    add_column :vacations, :status, :integer, :default => 1#vacation true
  end

  def self.down
    drop_column :vacations, :status
  end
end
