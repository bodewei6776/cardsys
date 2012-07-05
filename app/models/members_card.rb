# -*- encoding : utf-8 -*-
class MembersCard < ActiveRecord::Base
  set_table_name 'member_cards'

  include Authenticateable
  include HashColumnState
  has_many :logs, :as => :item

  belongs_to  :card
  belongs_to  :member
  has_many    :orders
  has_many    :member_card_granters, :foreign_key => "member_card_id"
  has_many    :granters, :class_name => "Member", :through => :member_card_granters
  has_many    :balances
  has_many :recharge_records, :foreign_key => :member_card_id

  delegate :name, :to => :member

  scope :autocomplete_for, lambda {|num| where("state = 'enabled' and lower(card_serial_num) like '#{num.downcase}%'").limit(10) }

  delegate :card_type_in_chinese, :is_counter_card?, :max_shared_count, :to => :card
  before_create :left_times_and_left_money_can_not_be_blank

  validates_presence_of :member_id, :message => "请选择会员"
  validates_presence_of :card_serial_num, :message => "请输入会员卡号"
  validates_uniqueness_of :card_serial_num, :message => "会员卡号冲突", :allow_blank => true

  attr_accessor :recharge_times, :recharge_fee, :recharge_expire_date, :recharging
  validates_numericality_of :recharge_times, :greater_than => -1, :message => "充值次数必须为大于零的整数", :if => proc {|obj| obj.recharging }
  #validates_numericality_of :recharge_fee, :greater_than => 0, :message => "充值金额必须为大于零的整数", :if => proc { |obj| obj.recharging }

  validation_conditions << proc {|obj| obj.recharging }

  def recharge_times= recharge_times
    self.recharging = true
    self.left_times += recharge_times.to_i
    @recharge_times = recharge_times
  end

  def recharge_fee= recharge_fee
    self.recharging = true
    self.left_fee += recharge_fee.to_i
    @recharge_fee = recharge_fee
  end

  def recharge_expire_date= recharge_expire_date
    self.recharging = true
    self.expire_date = Date.parse(recharge_expire_date.presence || self.expire_date.to_s)
    @recharge_expire_date = recharge_expire_date
  end

  def can_consume_goods?
  !self.card.is_counter_card? && self.card.is_consume_goods?
  end

  def max_granter_due?
    self.granters.count > max_shared_count - 1
  end


  def long_description
    card_serial_num + "   类型: " + card_type_in_chinese + "  " + left_fee_value + "  " + state_desc
  end

  def left_times_and_left_money_can_not_be_blank
    self.state = 'enabled'
    self.left_times = 0 if self.left_times.nil?
    self.left_fee = 0 if self.left_fee.nil?
  end

  def calculate_amount_in_time_span(date, start_hour, end_hour)
    if card.is_counter_card?
      end_hour - start_hour
    else
      card.calculate_amount_in_time_span(date,start_hour,end_hour)
    end
  end

  def expired?
    expire_date <= DateTime.now
  end

  def avalible?
    !expired? && enabled?
  end

  def is_useable_in_time_span?(book_record)
    return true unless book_record
    card.is_useable_in_time_span?(book_record.record_date,book_record.start_hour,book_record.end_hour)
  end

  #TODO
  def should_advanced_order?(start_hour,end_hour)
    true
  end

  def has_enough_money_to_record?(record)
    #TODO
  end

  def has_enough_money_to_balance?(balance)
    self.left_fee > balance.final_price
  end

  
  def has_enough_count_to_balance?(balance)
    self.left_times > balance.final_price
  end

  def member_card_type_opt
    return "" if self.card.nil?
    card.is_counter_card? ? "充次" : "充值"
  end


  def left_fee_value
   # unless card.is_zige_card?
   #   card.is_counter_card? ? "#{left_times.to_i} 次" : "￥#{left_fee.to_i}"
   # else
      "￥#{left_fee.to_i}元;#{left_times.to_i} 次"
   # end
  end

  def left_money_order_counter(balance = nil)
    card.is_counter_card? ||
      (card.is_zige_card? && balance && balance.use_card_counter_to_balance?) ?
      left_times : left_fee
  end


  def state_desc
     expired? ?  "已过期" : super
  end

  def has_less_count?
    (card.is_counter_card? || card.is_zige_card?) && left_times < Setting.minimum_warn_count
  end

  def has_less_fee?
    (!card.is_counter_card? || card.is_zige_card?) && left_fee < Setting.minimum_warn_amount
  end

  def less_fee_desc
    desc = ''
    desc << "卡余次不足#{Free_Count_Limit},请及时冲次" if has_less_count? 
    desc << "卡余额不足#{Free_Amount_limit}元，请及时充值" if has_less_fee?
  end

  def should_charge_counter?
    card.is_zige_card? || card.is_counter_card?
  end

  def should_recharge_amount?
    card.is_zige_card? || !card.is_counter_card?
  end
  
  def is_avalible?
    self.state == "enabled"
  end

  def order_tip_message
    msg = []
    msg << "卡已经过期，或者状态不正常" unless is_avalible?
    msg << less_fee_desc   unless less_fee_desc.blank?
    msg.join(';')
  end

  # 能否进行商品购买
  def can_buy_good?
    (!self.card.is_counter_card? && self.card.is_consume_goods?) ? "yes" : "no"
  end

  def remaining_money_and_amount_in_chinese
    self.left_fee_value + " / " + self.expire_date.strftime("%Y-%m-%d")
  end

  def members_card_info
    desc =  "#{state_desc} "
    desc += "（#{remain_amount_notice}）"  unless remain_amount_notice.blank?
    desc
  end

  def should_notice_remain_amount_due?(due_time = Time.now)
    (self.left_fee < (self.card.min_amount || 0)) || \
      (self.left_times < (self.card.min_count || 0)) || \
      (self.expire_date < (due_time + (self.card.min_time || 0).days)) 

  end

  def remain_amount_notice(due_time = Time.now)
    notices = []
    notices << "卡内余额不足" if (self.left_fee < (self.card.min_amount || 0))
    notices << "卡内次数不足"  if  (self.left_times < (self.card.min_count || 0)) 
    notices << "会员卡即将到期" if    self.expire_date < (due_time + (self.card.min_time || 0).days)
    notices.join(",")
  end

  def members_include_granters
    [member, granters].flatten.uniq
  end

  def is_ready_to_order?(order)
    clear_order_errors
    has_enough_amount_to_order?(order)
    should_order_in_time_span?(order)
    is_status_ready_to_order?
  end
  
  def granter_names
    granters.collect(&:name).join(" ,")
  end

  def can_edit?
    false
  end

  private
  def has_enough_amount_to_order?(order)
    #TODO
    true
  end

  def should_order_in_time_span?(order)
    unless is_useable_in_time_span?(order.book_record)
      book_record = order.book_record
      unusable_time_spans = card.unuseable_time_spans(book_record.record_date,book_record.start_hour,book_record.end_hour)
      unsuable_span_info = unusable_time_spans.map{|s,e|"#{s}:00-#{e}:00"}.join(';')
      order_errors << I18n.t('order_msg.member_card.invalid_time_span',:unusable_span => unsuable_span_info)
    end
  end

  def expire_date_to_s
    self.expire_date.to_s(:db)
  end

end
