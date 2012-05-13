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

  def self.log(controller, item, log_type, user, desc)
    user = user || controller.send("current_user")
    new(:remote_ip =>controller.request.remote_ip,
        :user_name => user.login,
        :user_id => user.id,
        :item => item,
        :log_type => log_type, 
        :desc => desc).save
  end

  def description
    item_name + ( LOG_TYPE[self.log_type.intern] || "" ) + ("(#{self.desc})" || "")
  end

  def item_name
    case item
    when Court
      item.name 
    when MembersCard
      item.card_serial_num
    else
     "" 
    end
  end
end
