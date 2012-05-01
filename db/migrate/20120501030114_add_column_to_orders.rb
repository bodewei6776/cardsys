class AddColumnToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :wdate, :integer
    add_column :orders, :batch_number, :string
    add_column :orders, :end_date, :date
  end
end
