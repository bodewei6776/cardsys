# -*- encoding : utf-8 -*-
class CreateBookRecords < ActiveRecord::Migration
  
  def self.up
    create_table :book_records  do |t|
      t.integer    :resource_id
      t.string     :resource_type
      t.integer    :end_hour,:start_hour
      t.date       :alloc_date
    end
  end

  def self.down
    drop_table :book_records
  end
  
end
