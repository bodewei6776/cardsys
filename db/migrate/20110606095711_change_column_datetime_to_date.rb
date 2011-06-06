class ChangeColumnDatetimeToDate < ActiveRecord::Migration
  def self.up
    change_column :rents,:start_date,:date
    change_column :rents,:end_date,:date
  end

  def self.down
    change_column :rents,:start_date,:datetime
    change_column :rents,:end_date,:datetime
  end
end
