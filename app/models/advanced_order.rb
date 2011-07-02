require "jcode"

class AdvancedOrder < ActiveRecord::Base
  
  belongs_to  :court
  belongs_to  :member
  has_many    :orders,:foreign_key => "parent_id",:dependent => :destroy
  
  validates :start_hour, :numericality => {:message => "开始时间必须为整数"},:presence => {:message => "请选择开始时间"}
  validates :end_hour, :numericality => {:message => "结束时间必须为整数"},:presence => {:message => "请选择结束时间"}
  validates :start_date,:end_date,:presence => {:message => "请选择开始结束日期"}
  validates :wday,:presence => {:message => "请选择选择星期"},
    :numericality => {:greater_than_or_equal_to => 1,:less_than_or_equal_to => 7,:message => "请选择正确的星期" }
  validates :court_id,:presence => {:message => "请选择场地"}
  
  validate :order_business_validate 
  
  before_update :destory_orginial_orders

  attr_accessor :updating
      
  def order_business_validate
    if start_date < Date.today
      errors[:base] << I18n.t('order_msg.advanced_order.old_start_date')
    elsif member.blank? || member_card.blank?
      errors[:base] << I18n.t('order_msg.advanced_order.member')
    elsif start_date > end_date
      errors[:base] << I18n.t('order_msg.advanced_order.valid_date')
    else
      errors[:base] << I18n.t('order_msg.advanced_order.conflict') if exist_conflict_book_record?
      new_orders = orders_between_start_and_end_date
      if invalid_order = new_orders.find{|order| !order.valid? }
        invalid_order.errors.each do |attribute, message| 
          errors[:base] << message
        end
      end
      unless member_card.should_advanced_order?(start_hour,end_hour)
        errors[:base] << I18n.t('order_msg.advanced_order.non_advanced_order')
      end
    end
  end
  
  def save(options={})
    return false unless super
    destroy_original_note_used_orders
    batch_order
    return true
  end
  
  def destroy
    destory_orginial_orders
    super
  end

  def destroy_original_note_used_orders
    original_orders = orders.where(["order_time >= ?",Date.today]).all
    original_orders.each do |original_order|
      unless orders_between_start_and_end_date.find{|new_order|
          new_order.book_record.record_date == original_order.book_reocrd.record_date }
        original_order.destroy
      end
    end
  end
  
  def destory_orginial_orders
    orders.where(["order_time >= ?",Date.today]).each { |order| order.destroy  }
  end
  
  def batch_order
    orders_between_start_and_end_date.each { |order|  
      order.parent_id  = self.id
      order.save 
    }
  end
  
  def order_dates_between_start_and_end_date
    (0...weeks_between_start_and_end_date).to_a.map { |wk|  realy_start_date + 7*wk}
  end
  
  def weeks_between_start_and_end_date
    start_cweek = start_cweek_of_day(start_date)
    if end_date.year > start_date.year #tow years
      prev_year_end_cweek   = end_cweek_of_day(end_of_prev_year)
      prev_year_min_weeks   = start_date.wday > wday || end_date.wday < wday ? 0 : 1
      prev_year_weeks = [prev_year_end_cweek - start_cweek,prev_year_min_weeks].max
      next_year_start_cweek  = start_cweek_of_day(beginning_of_next_year)
      next_year_end_cweek    = end_cweek_of_day(end_date)
      next_year_min_weeks    = end_date.beginning_of_year.wday < wday || end_date.beginning_of_year.wday > wday ? 0 : 1
      next_year_weeks = [next_year_end_cweek-next_year_start_cweek,next_year_min_weeks].max
      prev_year_weeks + next_year_weeks
    else
      end_cweek   = end_wday < wday ? end_date.cweek - 1 : end_date.cweek
      [end_cweek - start_cweek + 1,1].max
    end
  end
  
  def start_cweek_of_day(day)
    start_cweek = day.wday > wday ? day.cweek + 1 : day.cweek
    start_cweek > day.end_of_year.cweek ? start_cweek -= 1 : start_cweek
  end
  
  def end_cweek_of_day(day)
    end_cweek = day.wday < wday ? day.cweek - 1 : day.cweek
    end_cweek < day.beginning_of_year.cweek ? end_cweek += 1 : end_cweek
  end

  def original_orders
    new_record? ? [] : order
  end
  
  def orders_between_start_and_end_date
    @orders_between_start_and_end_date ||= order_dates_between_start_and_end_date.map { |record_date|
      book_record = new_book_record(record_date)
      order = book_record.new_record? ? Order.new : book_record.order
      order.member      = member
      order.member_card = member_card
      order.book_record = book_record
      order.coaches     = coaches
      order.operation   = :book
      order
    }
  end
  
  def orders_after_today
    orders.where(["order_time > ?",start_date.yesterday])
  end
  
  def book_records_between_start_and_end_date
    @orders.map(&:book_record)
  end
  
  def realy_start_date
    benchmark_date = start_wday > wday ? start_date + 7 : start_date
    (wday - start_wday).days.since(benchmark_date)
  end
  
  def realy_end_date
    benchmark_date = end_wday < wday ? end_date - 7 : end_date
    (end_wday - wday).days.ago(benchmark_date)
  end
  
  def start_wday
    start_date.blank? || start_date.wday == 0 ? 7 : start_date.wday
  end
  
  def end_of_prev_year
    if end_date.year > start_date.year && end_date.beginning_of_year.cweek == 52 
      end_date.beginning_of_year.end_of_week
    else
      end_date
    end
  end
  
  def beginning_of_next_year
    1.day.since(end_of_prev_year)
  end
  
  def end_wday
    end_date.blank? || end_date.wday == 0 ? 7 : end_date.wday
  end
  
  def exist_conflict_book_record?
    weekday_condition = if BookRecord.connection.adapter_name.downcase == 'mysql'
      "WEEKDAY(record_date)=#{wday-1}"
    else
      "date_part('dow',record_date)=#{wday}"
    end
    conflict_records = BookRecord.where(:court_id => court_id).where(weekday_condition).
      where("record_date>='#{start_date}' AND record_date<='#{end_date}'").
      where(["start_hour < :end_time AND end_hour > :start_time",{:start_time => start_hour,:end_time => end_hour}])
    return false if conflict_records.first.blank?
    if new_record?
      !conflict_records.first.blank?
    else
      !(conflict_records.select('id').all.map(&:id) - orders.map(&:book_record_id) ).blank?
    end
  end

  def original_book_record(record_date)
    return nil if new_record?
    book_record_relation = BookRecord.where(:record_date => record_date)
    book_record_relation = book_record_relation.joins("INNER JOIN orders ON book_records.id=orders.book_record_id AND orders.parent_id=#{id}")
    book_record = book_record_relation.all.first
    book_record = BookRecord.find(book_record.id) if book_record
    book_record
  end
  
  def new_book_record(record_date)
    book_record = new_record? ?  nil : original_book_record(record_date)
    book_record ||= BookRecord.new
    book_record.status = BookRecord::Status_Default
    book_record.record_date = record_date
    book_record.start_hour  = start_hour
    book_record.end_hour    = end_hour
    book_record.court_id    = court_id
    book_record 
  end
  
  def member
    return @member if new_record?
    @member ||= Member.find(member_id)
  end
      
  def member_attributes=(member_attributes)
    if member_attributes[:id].to_i > 0
      self.member_id = member_attributes[:id]
      @member = Member.find(member_attributes[:id])
    end
  end
  
  def member_card
    return @member_card if new_record?
    @member_card ||=  MemberCard.find(member_card_id)
  end

  def coaches
    updating ? @coaches : original_coaches
  end

  def original_coaches
    new_record? || orders.blank? ? [] : orders.first.coaches
  end

  def member_card_attributes=(member_card_attributes)
    unless member_card_attributes[:id].blank?
      @member_card = MemberCard.find_by_card_serial_num(member_card_attributes[:id])
      self.member_card_id = @member_card.id
    end
    @updating = true
  end

  def coach_attributes=(coach_attri)
    unless coach_attri[:id].blank?
      @coaches = coach_attri[:id].uniq.delete_if{|c_id|c_id.to_i <= 0 }.map{|coach_id| Coach.find(coach_id) }
    end
    @updating = true
  end

  def order_and_order_after(o)
    self.orders.select{|o| o.book_record.record_date >= o.book_record.record_date}
  end

  
end
