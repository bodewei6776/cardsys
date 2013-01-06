# -*- encoding : utf-8 -*-
class BookRecord < ActiveRecord::Base
  Status_Default     = 0  #等待与等
  Status_Prearranged = 1  #已预定
  Status_Settling    = 2  #已结算
  Status_cancel      = 3  #已取消
  Status_Agent       = 11 #代买中
  Status_Active      = 12 #打开中
  Status_Do_Agent    = 13

  All_Operations = [:book,:agent,:active,:balance,:cancel,:do_agent,:change_coaches]
  OPERATION_MAP = {:book => "预定",
    :agent => "申请代卖",
    :do_agent => "代卖",
    :balance => "结算",
    :active => "开场",
    :cancel => "取消预定",
    :change_coaches => "变更教练"}

  belongs_to  :order
  belongs_to  :resource, :polymorphic => true
  has_many :order_items, :as => :item, :dependent => :destroy

  scope :daily_book_records, lambda {|date| where(:alloc_date => date) }
  scope :court_book_records, lambda {|court_id| where(:court_id => court_id) }
  scope :playing, where(:status => Status_Active)
  scope :balanced, where(:status => Status_Settling)

  def start_time
    alloc_date + start_hour.hours
  end

  def end_time
    alloc_date + end_hour.hours
  end


  def start_date_time
    day = self.alloc_date.to_datetime
    Time.local(day.year, day.month, day.day, start_hour)
  end

  def end_date_time
    day = self.alloc_date.to_datetime
    if end_hour == 24
      Time.local(day.year,day.month,day.day,23,59)
    else
      Time.local(day.year,day.month,day.day,end_hour)
    end
  end

  def name
    resource.try(:name)
  end

  def agent_to_buy_condition
    CommonResource.agent_to_buy_time.hours.ago(self.start_date_time) >= DateTime.now 
  end

  def cancel_condition
    CommonResource.cancel_time.hours.ago(self.start_date_time) >= DateTime.now
  end

  def change_conditions
    CommonResource.change_time.hours.ago(self.start_date_time) > DateTime.now
  end

  #开场前半小时到结束时段
  def active_conditions
    self.alloc_date.beginning_of_day == Time.now.beginning_of_day
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

  def should_to_cancel?
    is_booked? && cancel_condition
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


  def status_desc
    desc = case
           when  booked?      then   expired? ? "已预定(过期)" : "已预定"
           when  balanced?    then   "已结算"
           when  canceld?     then   "已取消"
           when  agented?     then
             expired? ? "停止代买" : "代卖中"
           when  actived?      then   "开打中"
           else "过期"
           end
    desc
  end

  def status_color
    color = case
            when  is_default?      then  ""
            when  is_booked?         then  "color01"
            when  is_balanced?       then  "color05"
            when  is_canceld?        then  ""
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

  def amount
    order.is_member? ? amount_by_card : amount_by_court
  end

  def amount_desc(order_item = nil)
    (order.is_member? && order.member_card.card.is_counter_card?) ?  "#{amount}次" : "￥#{amount}"
  end

  def amount_by_court
    court.calculate_amount_in_time_span(alloc_date,start_hour,end_hour)
  end

  def amount_by_card
    order.members_card.calculate_amount_in_time_span(alloc_date,start_hour,end_hour)
  end

  def consecutive?
    self.order.is_advanced_order?
  end


  def exist_conflict_record?
    conlict_record = conflict_record_in_time_span
    conlict_record && (original_book_reocrd.nil? && conlict_record.id != id  || original_book_reocrd.id != conlict_record.id)
  end

  def conflict_record_in_time_span
    conflict_record = self.class.where(:alloc_date => alloc_date,:court_id => court_id).where(["start_hour < :end_time AND end_hour > :start_time",
                                                                                                {:start_time => start_hour,:end_time => end_hour}])
    conflict_record = conflict_record.where("id<>#{self.id}") unless new_record?
    conflict_record.first
  end

  private

  def is_time_span_ready_to_order?
    if end_hour  <= start_hour
      order_errors << I18n.t('order_msg.book_record.invalid_time_span')
    elsif  !is_to_do_agent? and exist_conflict_record? 
      order_errors << I18n.t('order_msg.book_record.exist_time_span',:date => alloc_date.to_s(:db),:start_time => start_hour,:end_time => end_hour)
    elsif is_to_do_agent? && (conlict_record = conflict_record_in_time_span)
      if is_a_valid_agented_record?(conlict_record)
        I18n.t('order_msg.book_record.invalid_agent',:start_time => conlict_record.start_hour,
               :end_time => conlict_record.end_hour)
      end
    end
  end

end
