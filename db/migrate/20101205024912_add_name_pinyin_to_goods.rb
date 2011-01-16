class AddNamePinyinToGoods < ActiveRecord::Migration
  def self.up
    add_column :goods, :name_pinyin, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :goods, :name_pinyin
  end
end
