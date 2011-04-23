class Card < ActiveRecord::Base

  has_many :member_cards
  has_many :card_period_prices

  ##default_scope lambda { where({:catena_id => current_catena.id})  }


  CONSUME_TYPE_1 = 1 #场地消费
  CONSUME_TYPE_2 = 2 #可买商品
  
  scope :search_order, order("created_at desc")
  
  validates :name, :presence => {:message => "卡名称不能为空！"}
  validates :name, :uniqueness => {:on => :create, :message => '卡名称已经存在！', 
    :if => Proc.new { |card| !card.name.nil? && !card.name.blank? }}
    
  validates :card_prefix, :presence => {:message => "卡前缀不能为空！"}
  validates :expired, :numericality => true, :presence => {:message => "有效期不能为空！"}
  validates_numericality_of :min_time ,:only_integer => true,:greater_than => -1,:message => "提醒时间必须为非负整数",:allow_nil => true
  validates_numericality_of :min_amount,:only_integer => true,:greater_than => -1,:message => "提醒金额必须为非负整数",:allow_nil => true
  validates_numericality_of :min_count,:only_integer => true,:greater_than =>-1,:message => "提醒次数必须为非负整数",:allow_nil => true

  before_save :auto_fill_nil
  def auto_fill_nil
    self.min_count = 0 if self.min_count.nil?
    self.min_amount = 0 if self.min_amount.nil?
    self.min_time = 0 if self.min_time.nil?
  end

  def card_type_record
    @card_type_record ||= (CommonResourceDetail.find_by_id(card_type) || '')
    @card_type_record.blank? ? nil : @card_type_record
  end
  
  def is_counter_card?
    card_type_record && card_type_record.is_counter_card_type?
  end

  def is_balance_card?
    card_type_record && card_type_record.is_balance_card_type?
  end

  def is_member_card?
    card_type_record && card_type_record.is_member_card_type?
  end

  def is_zige_card?
    card_type_record && card_type_record.is_zige_card_type?
  end
  
  def card_balance_desc
    self.is_counter_card? ? "#{self.counts||0}次" : "#{self.balance||0}元"
  end

  def status_desc
    if status == 1
      return "使用中"
    elsif status == 0
      return "未使用"
    elsif status == 2
      return "已停用"
    elsif status == 3
      return "已注销"
    else
      return "已注销"
    end
  end

  def generate_card_period_price(period_price)
    self.card_period_prices.find_all_by_period_price_id(period_price.id).first
  end

  def calculate_amount_in_time_span(date,start_hour,end_hour)
    PeriodPrice.calculate_amount_in_time_spans(date,start_hour,end_hour) do |period_price|
      card_period_price = self.card_period_prices.first(:conditions => "period_price_id=#{period_price.id}")
      [!card_period_price.nil? ,card_period_price.card_price]
    end
  end

  def all_periods_in_time_span(date = Date.today, start_time=nil, end_time=nil)
    card_period_prices.all.map(&:period_price).find_all{|period_price|
      period_price.is_in_time_span(date, start_time, end_time)
    }.sort{|fst,scd| fst.start_time <=> scd.start_time }
  end

  def unuseable_time_spans(date,start_hour,end_hour)
    period_prices = all_periods_in_time_span(date,start_hour,end_hour)
    time_spans = period_prices.map{|period_price|
      [period_price.start_time,period_price.end_time]
    }
    time_span_items = []
    time_spans.each {|time_span|
      time_span.first.upto(time_span.last-1){|i|time_span_items << [i,i+1]  }
    }
    order_time_span_items = []
    start_hour.upto(end_hour-1).each {|i| order_time_span_items << [i,i+1] }
    order_time_span_items.delete_if { |start_h,end_h| time_span_items.find{|s,n|start_h == s && end_hour = n}  }
  end

  def is_useable_in_time_span?(date,start_hour,end_hour)
    unuseable_time_spans(date,start_hour,end_hour).blank?
  end

  def should_advanced_order?
    is_member_card?
  end
  
  def card_type_desc
    unless @card_type_desc
      detail = CommonResourceDetail.find_by_id(card_type)
      @card_type_desc = (detail ? detail.detail_name : '')
    end
    @card_type_desc
  end

  def card_type_opt
    if is_member_card?
      "充值："
    elsif is_balance_card?
      "充值："
    else
      "充次："
    end
  end

  def is_consume_goods?
    self.consume_type == CONSUME_TYPE_2
  end
end

