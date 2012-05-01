class UpdateOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :advanced_order_id
    add_column :orders, :is_advance_order, :boolean
  end

  def down
    remove_column :orders, :is_advance_order
    add_column :orders, :advanced_order_id, :integer
  end
end
