# -*- encoding : utf-8 -*-
class CreateMemberCardGranters < ActiveRecord::Migration
  def self.up
    create_table :member_card_granters do |t|
      t.integer :member_card_id
      t.integer :granter_id
      t.integer :member_id
      t.timestamps
    end
  end

  def self.down
    drop_table :member_card_granters
  end
end
