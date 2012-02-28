# -*- encoding : utf-8 -*-
class CreateDepartmentPowers < ActiveRecord::Migration
  def self.up
    create_table :department_powers  do |t|
      t.integer :department_id, :power_id
      t.timestamps
    end
  end

  def self.down
    drop_table :department_powers
  end
end
