class AddItemToLog < ActiveRecord::Migration
  def change
    add_column :logs, :item_type, :string
    add_column :logs, :item_id, :integer
  end
end
