class AddColumnToCatena < ActiveRecord::Migration
  def self.up
    add_column :catenas, :description, :string
    add_column :catenas, :status, :integer, :default => 1
    add_column :catenas, :contact, :string
    add_column :catenas, :telephone, :string
  end

  def self.down
    remove_column :catenas, :description
    remove_column :catenas, :status
    remove_column :catenas, :contact
    remove_column :catenas, :telephone
  end
end
