# -*- encoding : utf-8 -*-
class CreateCoaches < ActiveRecord::Migration
  def self.up
    create_table :coaches   do |t|
      t.string :name
      t.string :gender
      t.string :coach_type
      t.string :telephone
      t.string :email
      t.decimal :fee, :default => 0, :precision => 10, :scale => 2
      t.integer :cert_type
      t.string :cert_num
      t.text :description
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :coaches
  end
end
