class AddColumnsToLogs < ActiveRecord::Migration
  def change
    add_column :logs, :order_person, :string
    add_column :logs, :item_name, :string
    add_column :logs, :order_time, :string
    add_column :logs, :period, :string
    add_column :logs, :description, :string
  end
end
