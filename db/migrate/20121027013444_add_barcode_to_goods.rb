class AddBarcodeToGoods < ActiveRecord::Migration
  def change
    add_column :goods, :barcode, :string
  end
end
