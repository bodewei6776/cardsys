task :get_power_back => :environment do

  def t(s,scope)
    I18n.t(s,:scope => scope)
  end
  Power.delete_all
  Dir.glob("#{Rails.root}/app/controllers/*.rb").sort.each { |file| require_dependency file }
  #Dir.glob("#{Rails.root}/app/models/*.rb").sort.each { |file| require_dependency file }
  ApplicationController.subclasses.each do |c|
    (c.action_methods - ApplicationController.action_methods).each do |a|
      Power.create(:subject => (t(c.to_s,"controllers") + " | " + t(a,"actions")),
                   :controller => t(c.to_s,"controllers"),:action => t(a,"actions"),:description => (t(c.to_s,"controllers") + " | " + t(a,"actions")))
    end
  end
end

task :get_power=> :environment do
  Power.class_eval do
    before_create do |p| p.catena_id = 1 end
  end
  Power.delete_all

  Power.create(:parent_id => 0,:subject => "基础信息管理")
  Power.last.children.create(:subject => "时段价格管理")
  Power.last.children.create(:subject => "卡模版管理")
  Power.last.children.create(:subject => "场地管理")
  Power.last.children.create(:subject => "节假日管理")
  Power.last.children.create(:subject => "教练管理")

  Power.create(:parent_id => 0,:subject => "会员管理")
  Power.last.children.create(:subject => "会员列表")
  Power.last.children.create(:subject => "添加会员")
  Power.last.children.create(:subject => "高级查询")

  Power.create(:parent_id => 0,:subject => "会员卡管理")
  Power.last.children.create(:subject => "会员卡绑定")
  Power.last.children.create(:subject => "会员卡充值")
  Power.last.children.create(:subject => "授权人管理")
  Power.last.children.create(:subject => "停卡激活管理")

  Power.create(:parent_id => 0,:subject => "场地预定")
  Power.last.children.create(:subject => "新场地预定")
  Power.last.children.create(:subject => "新场地周期性预定")
  Power.last.children.create(:subject => "场地预定情况查询")
  Power.last.children.create(:subject => "教练日程查询")

  Power.create(:parent_id => 0,:subject => "商品库存管理")
  Power.last.children.create(:subject => "商品基本信息管理")
  Power.last.children.create(:subject => "商品后台库存管理")
  Power.last.children.create(:subject => "商品前台出库管理")

  Power.create(:parent_id => 0,:subject => "分析报表")
  Power.last.children.create(:subject => "教练分账报表")
  Power.last.children.create(:subject => "时间段内收入报表")
  Power.last.children.create(:subject => "会员消费明细")
  Power.last.children.create(:subject => "场地使用率")

  Power.create(:parent_id => 0,:subject => "消费结算")
  Power.last.children.create(:subject => "场地待结算列表")
  Power.last.children.create(:subject => "场地已结算列表")
  Power.last.children.create(:subject => "购买商品")

  Power.create(:parent_id => 0,:subject => "权限管理")
  Power.last.children.create(:subject => "用户管理")
  Power.last.children.create(:subject => "部门管理")
  Power.last.children.create(:subject => "连锁店管理")

  Power.create(:parent_id => 0,:subject => "系统管理")
  Power.last.children.create(:subject => "修改密码")
  Power.last.children.create(:subject => "操作日志")
  Power.last.children.create(:subject => "数据备份")
  Power.last.children.create(:subject => "关于软件")

end
