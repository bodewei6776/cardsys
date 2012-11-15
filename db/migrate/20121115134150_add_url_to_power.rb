# -*- encoding : utf-8 -*-
class AddUrlToPower < ActiveRecord::Migration
  def add_url(subject, url)
    Power.find_by_subject(subject).update_attribute(:description, url)
  end

  def change
    map = [["基础信息管理", "/period_prices"], ["时段价格管理", "/period_prices"], ["卡模板管理", "/cards"], ["场地管理", "/courts"], ["节假日管理", "/vacations"], ["教练管理", "/coaches"], ["储物柜管理", "/lockers/list"], ["会员管理", "/members"], ["会员列表", "/members"], ["添加会员", "/members/new"], ["高级查询", "/members/advanced_search"], ["会员卡管理", "/members_cards/new"], ["会员卡绑定", "/members_cards/new"], ["会员卡充值", "/members_cards/recharge"], ["授权人管理", "/members_cards/granters"], ["停卡激活管理", "/members_cards/status"], ["场地预定", "/orders"], ["新场地预定", "/orders"], ["新场地周期性预定", "/courts/court_status_search"], ["场地预定情况查询", "/courts/court_status_search"], ["教练日程查询", "/courts/coach_status_search"], ["修改场地", "xiugaichangdi"], ["结算场地", "jiesuanchangdi"], ["取消场地", "shanchuchangdi"], ["过期预定", nil], ["库存管理", "/goods"], ["基本信息管理", nil], ["后台库存管理", "/goods/back"], ["前台出库管理", "/goods/front"], ["分类管理", "/categories"], ["分析报表", "/reports/income"], ["教练分账报表", nil], ["日收入报表", "/reports/income"], ["月收入报表", "/reports/income_by_month"], ["会员消费明细", nil], ["场地使用率", nil], ["消费结算", "/balances/new_good_buy"], ["场地待结算列表", "/balances/unbalanced"], ["场地已结算列表", "/balances/balanced"], ["购买商品", "/balances/new_good_buy"], ["删除结算信息", nil], ["变更总价", nil], ["权限管理", "/users"], ["用户管理", "/users"], ["部门管理", "/departments"], ["连锁店管理", nil], ["储物柜", "/lockers"], ["租用记录", "/rents"], ["储物柜列表", "/lockers/list"], ["系统管理", "/logs"], ["修改密码", "/users/change_password"], ["操作日志", "/logs"], ["数据备份", "/backup"], ["关于软件", "/about"], ["销售统计表", "/reports/good_search"]]
    map.each do |a|
      add_url a[0], a[1]
    end
  end
end
