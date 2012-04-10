class ChangeColumnDiscount < ActiveRecord::Migration
  def up
    change_column :order_items, :discount, :decimal, :scale => 1, :precision => 8
  end

  def down
  end
end
