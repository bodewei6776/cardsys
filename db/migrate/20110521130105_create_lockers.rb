# -*- encoding : utf-8 -*-
class CreateLockers < ActiveRecord::Migration
  def self.up
    create_table :lockers do |t|
      t.string :num
      t.string :locker_type
      t.string :state
      t.string :remark

      t.timestamps
    end
  end

  def self.down
    drop_table :lockers
  end
end
