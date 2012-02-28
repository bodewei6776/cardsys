# -*- encoding : utf-8 -*-
class CreateCommonResources < ActiveRecord::Migration
  def self.up
    create_table :common_resources do |t|
      t.string :name
      t.text :description
      t.text :detail_str
      t.timestamps
    end
  end

  def self.down
    drop_table :common_resources
  end
end
