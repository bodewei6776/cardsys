# encoding: utf-8

class ChangeChuwuguiMenu < ActiveRecord::Migration
  def up
    Power.find(47).update_column(:subject, "储物柜")
    Power.find(49).update_column(:subject, "储物柜列表")
  end

  def down
  end
end
