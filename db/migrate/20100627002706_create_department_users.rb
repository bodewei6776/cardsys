# -*- encoding : utf-8 -*-
class CreateDepartmentUsers < ActiveRecord::Migration
  def self.up
    create_table :department_users do |t|
      t.integer :user_id
      t.integer :department_id
    end
  end

  def self.down
    drop_table :department_users
  end
end
