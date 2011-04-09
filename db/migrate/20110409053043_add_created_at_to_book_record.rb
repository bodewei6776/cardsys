class AddCreatedAtToBookRecord < ActiveRecord::Migration
  def self.up
    add_column :book_records,:created_at ,:datetime
    add_column :book_records,:updated_at ,:datetime
  end

  def self.down
    remove_column :book_records,:created_at
    remove_column :book_records,:updated_at
  end
end
