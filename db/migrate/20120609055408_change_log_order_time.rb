class ChangeLogOrderTime < ActiveRecord::Migration
  def up
    change_column :logs, :order_time, :datetime
  end

  def down
    change_column :logs, :order_time, :string
  end
end
