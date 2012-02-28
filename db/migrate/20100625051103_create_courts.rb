# -*- encoding : utf-8 -*-
class CreateCourts < ActiveRecord::Migration
  def self.up
    create_table :courts do |t|
      t.string     :name
      t.string     :contact
      t.string     :telephone
      t.integer    :start_time
      t.integer    :end_time
      t.text       :description
      t.string     :state
      t.timestamps
    end
  end

  def self.down
    drop_table :courts
  end
end
