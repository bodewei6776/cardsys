# -*- encoding : utf-8 -*-
#
class ChangeRentManagmentRecord < ActiveRecord::Migration
  def up
    p = Power.find_by_subject("出租管理")
    p.update_attribute("subject", "租用记录")
  end

  def down
    p = Power.find_by_subject("租用记录")
    p.update_attribute("subject", "出租管理")
  end
end
