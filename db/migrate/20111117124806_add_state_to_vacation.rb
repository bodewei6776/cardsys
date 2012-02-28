# -*- encoding : utf-8 -*-
class AddStateToVacation < ActiveRecord::Migration
  def self.up
    add_column :vacations, :state, :string
  end

  def self.down
    remove_column :vacations, :state, :string
  end
end
