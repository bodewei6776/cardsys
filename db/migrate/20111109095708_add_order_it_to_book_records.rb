class AddOrderItToBookRecords < ActiveRecord::Migration
  def self.up
    add_column :book_records, :order_id, :integer
  end

  def self.down
    remove_column :book_records, :order_id
  end
end
