class ChangeRelationShipBetweenOrderAndBookRecord < ActiveRecord::Migration
  def self.up
    remove_column :orders, :book_record_id
    add_column :book_records, :order_id, :integer
  end

  def self.down
    add_column :orders, :book_record_id, :integer
    remove_column :book_records, :order_id
  end
end
