# encoding: utf-8

class RemoveMenu < ActiveRecord::Migration
  def up
    Power.find_by_subject("新场地周期性预订")
  end

  def down
  end
end
