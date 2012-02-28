# -*- encoding : utf-8 -*-
class CreateNonMembers < ActiveRecord::Migration
  
  def self.up
    create_table :non_members  do |t|
      t.string     :name, :name_pinyin
      t.string     :telephone
      t.float      :earnest
    end
  end

  def self.down
    drop_table :non_members
  end
  
end
