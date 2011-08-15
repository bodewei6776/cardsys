class BookRecord < ActiveRecord::Base

  include BookRecordOrder

  Status_Default     = 0  #等待与等
  Status_Prearranged = 1  #已预定
  Status_Settling    = 2  #已结算
  Status_Cancle      = 3  #已取消
  Status_Agent       = 11 #代买中
  Status_Active      = 12 #打开中
  Status_Do_Agent    = 13

  All_Operations = [:book,:agent,:active,:balance,:cancle,:do_agent,:change_coaches]
  OPERATION_MAP = {:book => "预定",
                   :agent => "申请代卖",
                   :do_agent => "代卖",
                   :balance => "结算",
                   :active => "开场",
                   :cancle => "取消预定",
                   :change_coaches => "变更教练"}

  attr_accessor :original_book_reocrd
  
  validates :start_hour, :numericality => {:message => "开始时间必须为整数"}
  validates :end_hour, :numericality => {:message => "结束时间必须为整数"}

  has_one     :order
  belongs_to  :court
  
  scope :daily_book_records, lambda {|date| where(:record_date => date) }
  scope :court_book_records, lambda {|court_id| where(:court_id => court_id) }
  scope :playing, where(:status => Status_Active)
  scope :balanced,where(:status => Status_Settling)
  

  def before_create_init_attributes
    self.status = Status_Default
  end
  
  def start_date_time
    # utc local
    #start_hour.hours.since(self.record_date.to_datetime)
    day = self.record_date.to_datetime
    Time.local(day.year,day.month,day.day,start_hour)
  end

  def end_date_time
    #end_hour.hours.since(self.record_date.to_datetime)
    day = self.record_date.to_datetime
    if end_hour == 24
    Time.local(day.year,day.month,day.day,23,59)
    else
      Time.local(day.year,day.month,day.day,end_hour)
    end
  end

  def agent_to_buy_condition
    CommonResource.agent_to_buy_time.hours.ago(self.start_date_time) >= DateTime.now 
  end

  def cancle_condition
    CommonResource.cancle_time.hours.ago(self.start_date_time) >= DateTime.now
  end

  def change_conditions
    CommonResource.change_time.hours.ago(self.start_date_time) > DateTime.now
  end

  #开场前半小时到结束时段
  def active_conditions
    #CommonResource.active_time.minutes.ago < start_date_time && start_date_time < end_date_time
    #CommonResource.active_time.minutes.from_now > start_date_time && start_date_time < end_date_time
    self.record_date.beginning_of_day == Time.now.beginning_of_day
  end

  def should_book?
    is_default? || should_to_agent_to_buy? || is_to_do_agent?
  end

  def should_to_agent_to_buy?
    is_agented? && agent_to_buy_condition
  end

  def should_application_to_agent?
    is_booked? && agent_to_buy_condition 
  end

  def should_to_cancle?
    is_booked? && cancle_condition
  end

  def should_changed?
    is_booked? && change_conditions
  end

  def should_to_active?
    (is_booked? || is_agented?) && active_conditions
  end

  #TODO
  def should_to_balance?
    is_actived?
  end

  def should_blance_as_expired?
    # is_agented 包含了时间条件判断
    #(is_booked? || is_agented?) && is_expired?
    (is_booked? || status == Status_Agent) && is_expired?
  end
  
  def book
    self.status = Status_Prearranged
    save
  end

  def is_booked?
    status == Status_Prearranged
  end

  def do_balance
    self.update_attribute(:status, Status_Settling)
  end

  def is_balanced?
    status == Status_Settling
  end

  def is_expired?
    end_date_time <= Time.now
  end

  def agent
    if id.to_i > 0 && (db_book_record = self.class.find(self.id))
      self.attributes = db_book_record.attributes.except(:id)
    end
    self.status = Status_Agent
    save
  end

  def cancle_agent
    if id.to_i > 0 && (db_book_record = self.class.find(self.id))
      self.attributes = db_book_record.attributes.except(:id)
    end
    self.status = Status_Prearranged
    save
  end

  def is_a_valid_agented_record?(original_book_record)
    true
  end
  
  def less_or_equle_then?(other_book_record)
    other_book_record.start_hour <= start_hour  && other_book_record.end_hour >= end_hour
  end

  def is_more_then?(other_book_record)
    other_book_record.start_hour > start_hour && other_book_record.end_hour < end_hour
  end

  def is_not_overlap_with?(other_book_record)
    other_book_record.end_hour <= start_hour || other_book_record.start_hour >= end_hour
  end

  def do_agent(new_order)
    new_book_record = new_order.book_record
    if is_not_overlap_with?(new_book_record)
      #do nothing,a new book record
    elsif is_more_then?(new_book_record)
      #TODO
    elsif less_or_equle_then?(new_book_record)
      destroy
    elsif new_book_record.start_hour != start_hour
      if new_book_record.start_hour > start_hour
        self.end_hour = new_book_record.start_hour
      else
        self.start_hour = new_book_record.end_hour 
      end
      save
    elsif new_book_record.end_hour != end_hour
      if new_book_record.end_hour < end_hour
        self.start_hour = new_book_record.end_hour
      else
        self.end_hour = new_book_record.start_hour
      end
      save
    end
  end

  def is_agented?
    status == Status_Agent && !is_expired?
  end

  def active
    self.status = Status_Active
    save
  end

  def is_to_do_agent?
    status ==  Status_Do_Agent && !is_expired?
  end

  def is_actived?
    status == Status_Active
  end

  def cancle
    destroy
  end

  def is_cancled?
    status == Status_Cancle
  end

  def is_default?
    status.to_i == Status_Default
  end
  
  def change_coaches
    #Do nothing
  end

  def route_operation(operation)
    operation = self.class.default_operation if operation.blank?
    operation = operation.to_sym
    raise "invalid operation,not responsed to #{operation}" unless All_Operations.include?(operation)
    send(operation)
  end

  def status_desc
    desc = case
    when  is_default?    then   "预定"
    when  is_booked?      then   is_expired? ? "已预定(过期)" : "已预定"
    when  is_balanced?    then   "已结算"
    when  is_cancled?     then   "已取消"
    when  is_agented?     then
      is_expired? ? "停止代买" : "代卖中"
    when  is_actived?      then   "开打中"
    else "过期"
    end
    desc
  end
  
  def status_color
    color = case
    when  is_default?      then  ""
    when  is_booked?         then  "color01"
    when  is_balanced?       then  "color05"
    when  is_cancled?        then  ""
    when  is_agented?        then  "color04"
    when  is_actived?        then  "color03"
    when  status == Status_Agent        then  "color04"
    else "color02"
    end
    color
  end

  def hours
    end_hour - start_hour
  end

  def self.default_operation
    :book
  end
  
  def amount(order_item = nil)
    order.is_member? ? amount_by_card : amount_by_court
  end
  
  def amount_desc(order_item = nil)
    if order.is_member? && order.member_card.card.is_counter_card?
      "#{amount}次"
    else
      "￥#{amount}"
    end
  end
  
  def amount_by_court
    court.calculate_amount_in_time_span(record_date,start_hour,end_hour)
  end
  
  def amount_by_card
    order.member_card.calculate_amount_in_time_span(record_date,start_hour,end_hour)
  end

  def consecutive?
    self.order.is_advanced_order?
  end
  
end
