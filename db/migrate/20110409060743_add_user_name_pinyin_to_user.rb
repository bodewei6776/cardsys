# -*- encoding : utf-8 -*-
class AddUserNamePinyinToUser < ActiveRecord::Migration
  def self.up
    add_column :users,:user_name_pinyin,:string
  end

  def self.down
    remove_column :users,:user_name_pinyin
  end
end
