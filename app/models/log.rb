# -*- encoding : utf-8 -*-
class Log < ActiveRecord::Base
  belongs_to :item, :polymorphic => true

  LOG_TYPE = {
    :kaika           => "开卡",
    :chongzhi        => "充值",
    :biangengzongjia => "变更总价",
    :book => "预定",
    :want_sell => "申请代卖",
    :sell => "代卖",
    :activate => "开场",
    :cancel => "取消预定",
    :change => "变更"
  }
  before_save do |obj|
    obj.order_person = self.order_person_getter
    obj.item_name = self.item_name_getter
    obj.order_time = self.order_time_getter
    obj.period = self.period_getter
    obj.description = self.description_getter
  end

  def self.log(controller, item, log_type, user, desc)
    user = user || controller.send("current_user")
    new(:remote_ip =>controller.request.remote_ip,
        :user_name => user.login,
        :user_id => user.id,
        :item => item,
        :log_type => log_type, 
        :desc => desc).save
  end

  def description_getter
    item_name + ( LOG_TYPE[self.log_type.intern] || "" ) + ("(#{self.desc})" || "")
  end

  def period_getter
    return "" unless BookRecord === self.item 
    "#{self.item.start_hour}:00 - #{self.item.end_hour}:00"
  end

  def order_time_getter
    return "" unless BookRecord === self.item 
    self.item.order.created_at
  end

  def order_person_getter
    return "" unless BookRecord === self.item 
    self.item.order.member_name
  end

  def item_name_getter
    case item
    when BookRecord
      item.court.name 
    when MembersCard
      item.card_serial_num
    else
      "" 
    end
  end
end
