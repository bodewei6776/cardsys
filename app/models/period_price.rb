# -*- encoding : utf-8 -*-
class PeriodPrice < ActiveRecord::Base

  has_many :card_period_prices

  scope :search_order, PeriodPrice.order("period_type desc, name desc, created_at desc")

  validates :name,  :presence => {:message => "时段名称不能为空！"}
  validates :price, :numericality => {:message => "时段价格必须为数字！"}
  #validates :period_type, :uniqueness => {:scope => [:start_time, :end_time], :message => "该价格时段已经存在，请重新设置价格时段！"}

  validate :validate_start_time_end_time

  PERIOD_START_TIME, PERIOD_END_TIME  = 7, 24

  def validate_start_time_end_time
    self.errors.add(:base, "开始时间应小于结束时间") if self.start_time >= self.end_time 
    #conflict_period = self.class.where(["start_time < :end_time AND end_time > :start_time AND period_type=#{period_type}",
    #    {:start_time => start_time,:end_time => end_time}])
    #conflict_period = conflict_period.where("id <> #{id}") unless new_record?
    #if conflict_period.first
    #  errors['base'] << "时段冲突，#{start_time}-#{end_time}已经存在"
    #end
  end

  def period_type_in_chinese
    CommonResourceDetail.find(period_type).detail_name
  end

  def is_fit_for?(date)
    date_type = CommonResource.date_type(date)
    self.period_type.to_i == date_type.id
  end

  def is_in_time_span(date = Date.today, start_hour = nil, end_hour = nil)
    start_hour ||= PERIOD_START_TIME
    end_hour   ||= PERIOD_END_TIME
    date_type = CommonResource.date_type(date||Date.today)
    date_type && period_type == date_type.id && start_time < end_hour && end_time > start_hour
  end

  #取得某一天中给定时间段的时段价格
  def self.all_periods_in_time_span(date = Date.today, start_time=nil, end_time=nil)
    start_time ||= PERIOD_START_TIME
    end_time   ||= PERIOD_END_TIME
    date_type = CommonResource.date_type(date || Date.today)
    pp = PeriodPrice.where(:period_type => date_type.id).order("start_time asc")
    pp.select{ |element| element.start_time < end_time && element.end_time > start_time }
  end


  def self.period_by_date_and_start_hour(date, start_hour)
    @pp_store ||= {}
    @date_type ||= CommonResource.date_type(date)
    pp = @pp_store[@date_type.id]
    unless pp
      pp = PeriodPrice.where(:period_type => @date_type.id) 
      @pp_store[@date_type.id] = pp
    end
    pp.select { |element| element.start_time <= start_hour && element.end_time >= start_hour + 1}
  end

  def self.calculate_amount_in_time_spans(date, start_hour, end_hour)
    start_hour,end_hour = start_hour.to_i,end_hour.to_i
    period_prices = all_periods_in_time_span(date,start_hour,end_hour)
    period_prices.sort!{|fst,scd| scd.start_time <=> fst.start_time }
    amount,leave_end_hour = 0,end_hour
    period_prices.each do |period_price|
      condition, price = yield period_price
      realy_end_hour = [start_hour,period_price.start_time].max
      next unless condition
      amount += (leave_end_hour - realy_end_hour)*price
      leave_end_hour = realy_end_hour
    end
    amount
  end

  def can_destroy?
    self.card_period_prices.blank?
  end

end

