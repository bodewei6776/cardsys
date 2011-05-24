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
  
 Power.all.collect(&:destroy)
  a = Power.create(:parent_id => 0,:subject => "基础信息管理")
  a.children.create(:subject => "时段价格管理")
  a.children.create(:subject => "卡模板管理")
  a.children.create(:subject => "场地管理")
  a.children.create(:subject => "节假日管理")
  a.children.create(:subject => "教练管理")
  a.children.create(:subject => "储物柜管理")

 a= Power.create(:parent_id => 0,:subject => "会员管理")
  a.children.create(:subject => "会员列表")
  a.children.create(:subject => "添加会员")
  a.children.create(:subject => "高级查询")

  a= Power.create(:parent_id => 0,:subject => "会员卡管理")
  a.children.create(:subject => "会员卡绑定")
  a.children.create(:subject => "会员卡充值")
  a.children.create(:subject => "授权人管理")
  a.children.create(:subject => "停卡激活管理")

  a=Power.create(:parent_id => 0,:subject => "场地预定")
  a.children.create(:subject => "新场地预定")
  a.children.create(:subject => "新场地周期性预定")
  a.children.create(:subject => "场地预定情况查询")
  a.children.create(:subject => "教练日程查询")
  a.children.create(:subject => "修改场地",:description => "xiugaichangdi")
  a.children.create(:subject => "结算场地",:description => "jiesuanchangdi")
  a.children.create(:subject => "删除场地预定",:description => "shanchuchangdi")
  a.children.create(:subject => "过期预定")

  a=Power.create(:parent_id => 0,:subject => "库存管理")
  a.children.create(:subject => "基本信息管理")
  a.children.create(:subject => "后台库存管理")
  a.children.create(:subject => "前台出库管理")
  a.children.create(:subject => "分类管理")

  a=Power.create(:parent_id => 0,:subject => "分析报表")
  a.children.create(:subject => "教练分账报表")
  a.children.create(:subject => "日收入报表")
  a.children.create(:subject => "月收入报表")
  a.children.create(:subject => "会员消费明细")
  a.children.create(:subject => "场地使用率")

  a=Power.create(:parent_id => 0,:subject => "消费结算")
  a.children.create(:subject => "场地待结算列表")
  a.children.create(:subject => "场地已结算列表")
  a.children.create(:subject => "购买商品")
  a.children.create(:subject => "删除结算信息")
  a.children.create(:subject => "变更总价")

  a=Power.create(:parent_id => 0,:subject => "权限管理")
  a.children.create(:subject => "用户管理")
  a.children.create(:subject => "部门管理")
  a.children.create(:subject => "连锁店管理")

  a=Power.create(:parent_id => 0,:subject => "储物柜管理")
  a.children.create(:subject => "出租管理")
  a.children.create(:subject => "储物柜管理")


  a=Power.create(:parent_id => 0,:subject => "系统管理")
  a.children.create(:subject => "修改密码")
  a.children.create(:subject => "操作日志")
  a.children.create(:subject => "数据备份")
  a.children.create(:subject => "关于软件")

  admin = User.find_by_login('admin')
  admin.powers << Power.all
  admin.save

end
