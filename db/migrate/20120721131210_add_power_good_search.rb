# encoding: utf-8
#
class AddPowerGoodSearch < ActiveRecord::Migration
  def up
    #Power.create(:subject => "销售统计表", :parent_id => Power.find_by_subject("分析报表").id)
  end

  def down
  end
end
