# -*- encoding : utf-8 -*-
class RenameOrderDelete < ActiveRecord::Migration
  def up
    p = Power.find_by_subject("删除场地预定")
    p.update_attribute("subject", "取消场地")
  end

  def down
    p = Power.find_by_subject("取消场地")
    p.update_attribute("subject", "删除场地预定")
  end
end
