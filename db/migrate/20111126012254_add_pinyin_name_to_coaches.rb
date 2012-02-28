# -*- encoding : utf-8 -*-
class AddPinyinNameToCoaches < ActiveRecord::Migration
  def self.up
    add_column :coaches, :pinyin_name, :string
  end

  def self.down
    remove_column :coaches, :pinyin_name
  end
end
