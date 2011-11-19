class AddTypeToBookRecord < ActiveRecord::Migration
  def self.up
    add_column :book_records, :type, :string
  end

  def self.down
    remove_column :book_records, :type
  end
end
