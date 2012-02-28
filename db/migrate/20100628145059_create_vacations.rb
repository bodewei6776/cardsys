# -*- encoding : utf-8 -*-
class CreateVacations < ActiveRecord::Migration
  def self.up
    create_table :vacations  do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :vacations
  end
end
