class MemberCard < ActiveRecord::Base

  include MemberCardOrder
  
  belongs_to  :card
  belongs_to  :member
  has_many    :orders
  has_many :member_card_granters
  has_many :granters,:class_name => "Member",:through => :member_card_granters

  #validates :left_fee ,:presence => true
  #validates :left_times,:presence => true

  scope :autocomplete_for, lambda {|num| where("status = 0 and card_serial_num like '#{num.downcase}%'").limit(10) }

  CARD_STATUS_0 = 0 #正常
  CARD_STATUS_1 = 1 #已注销
  
  Free_Count_Limit = 2
  Free_Amount_limit = 500


  attr_accessor :notice

  def max_granter
    if self.card.shared_amount.nil? or self.card.shared_amount.zero?
      1000
    else
      self.card.shared_amount
    end
  end

  def balances
    Balance.find_all_by_book_reocrd_member_card_id(self.id) & Balance.find_all_by_goods_member_card_id(self.id)
  end

  def max_granter_due?
    self.max_granter <= self.granters.count
  end

  def enable?
    self.status == CARD_STATUS_0
  end

  before_create :left_times_and_left_money_can_not_be_blank

  def left_times_and_left_money_can_not_be_blank
    self.left_times = 0 if self.left_times.nil?
    self.left_fee = 0 if self.left_fee.nil?
  end

  validates :card_serial_num,:uniqueness => {:message => "卡号已经存在，请更换卡号"}


  def calculate_amount_in_time_span(date,start_hour,end_hour)
    if card.is_counter_card?
      end_hour - start_hour
    else
      card.calculate_amount_in_time_span(date,start_hour,end_hour)
    end
  end

  def is_expired?
    expire_date <= DateTime.now
  end

  def is_avalible?
    !is_expired? && is_status_valid?
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
    left_mouny_order_counter(balance) >= balance.amount_by_card
  end

  def member_card_type_opt
    return "" if self.card.nil?
    card.is_counter_card? ? "充次" : "充值"
  end

#  def member_card_granters
#    mcgs = []
#    MemberCardGranter.where(:member_card_id => self.id).each { |e|
#      mcgs << Member.find(e.member_id ).first.name
#    }
#    mcgs
#  end

  def left_fee_value
    unless card.is_zige_card?
      card.is_counter_card? ? "#{left_times.to_i} 次" : "￥#{left_fee.to_i}"
    else
      "￥#{left_fee.to_i}元;#{left_times.to_i} 次"
    end
  end
   
  def left_mouny_order_counter(balance = nil)
    card.is_counter_card? ||
      (card.is_zige_card? && balance && balance.use_card_counter_to_balance?) ?
      left_times : left_fee
  end
   
  def is_status_valid?
    self.status == 0
  end

  def member_card_status_opt
    self.status == 0 ? "正常" : "已注销"
  end
  
  def status_desc
    if is_expired?
      "已过期"
    else
      member_card_status_opt
    end
  end
  
  def has_less_count?
    (card.is_counter_card? || card.is_zige_card?) && left_times < Free_Count_Limit
  end
  
  def has_less_fee?
    (!card.is_counter_card? || card.is_zige_card?) && left_fee < Free_Amount_limit
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

  def order_tip_message
    msg = []
    msg << "卡已经过期，或者状态不正常" unless is_avalible?
    msg << less_fee_desc   unless less_fee_desc.blank?
    msg.join(';')
  end
  
  #TODO
  def do_balance(order)
    balance_record = Balance.find_by_order_id(order.id)
    if card.is_counter_card? || (card.is_zige_card? && balance_record.use_card_counter_to_balance?)
      self.left_times -= balance_record.count_amount
    else
      if balance_record.use_card_to_balance_book_record?
        self.left_fee -= balance_record.book_record_realy_amount.to_i
      end
      if balance_record.use_card_to_balance_goods? 
        raise "卡#{card.card_serial_num}不能购买商品" unless order.should_use_card_to_balance_goods?
        self.left_fee -= balance_record.goods_realy_amount.to_i
      end
    end
    save
  end

  # 能否进行商品购买
  def can_buy_good
    (!self.card.is_counter_card? && self.card.is_consume_goods?) ? "yes" : "no"
  end

  def member_info
    self.member_name + "( #{self.member_phone })"
  end

  def card_info
    self.left_fee_value + " / " + self.expire_date.strftime("%Y-%m-%d")
  end

  def member_name
    member.name
  end

  def member_phone
    (member.mobile + "/" + member.telephone) rescue "未知"
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

end
