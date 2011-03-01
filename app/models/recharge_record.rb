class RechargeRecord < ActiveRecord::Base

  belongs_to :member_card
  belongs_to :member

  def display_recharge_info
    recharge_fee.to_i == 0 ? "#{recharge_times}次" : "￥#{recharge_fee}元"
  end
  
end
