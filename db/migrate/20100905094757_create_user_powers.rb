# -*- encoding : utf-8 -*-
class CreateUserPowers < ActiveRecord::Migration
  def self.up
    create_table :user_powers do |t|
      t.integer :user_id, :power_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_powers
  end
end
