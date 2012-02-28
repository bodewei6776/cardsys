# -*- encoding : utf-8 -*-
class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members  do |t|
      t.string :name, :name_pinyin
      t.string  :pinyin_abbr
      t.string :nickname
      t.string :gender
      t.datetime :birthday
      t.string :telephone
      t.string :mobile
      t.string :email
      t.string :address
      t.string :job
      t.integer :cert_type
      t.string :cert_num
      t.string :memo
      t.string :mentor
      t.integer :fax
      t.text :description
      t.string :state
      t.boolean :granter 
      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
