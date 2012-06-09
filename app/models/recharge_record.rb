# -*- encoding : utf-8 -*-
class RechargeRecord < ActiveRecord::Base

  belongs_to :members_card, :foreign_key => :member_card_id
  belongs_to :member

  delegate :card_serial_num, :to => :members_card

  def display_recharge_info
    recharge_fee.to_i == 0 ? "#{recharge_times}次" : "￥#{recharge_fee}元"
  end

  def recharge_person_name
    User.find(self.recharge_person).user_name rescue ""
  end
  
end
