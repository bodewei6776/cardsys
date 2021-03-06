# -*- encoding : utf-8 -*-
class Court < ActiveRecord::Base
  include HashColumnState

  has_many :court_period_prices
  has_many :period_prices, :through => :court_period_prices
  has_many :book_records, :as => :resource

  validates :name, :presence => {:message => "场地名称不能为空！"}
  validates :name, :uniqueness => {:on => :create, :message => '场地名称已经存在了！', :if => Proc.new { |court| !court.name.nil? && !court.name.blank? }}
  validates :telephone, :numericality => {:only_integer => true, :message => "电话号码必须为数字！", :allow_blank => true}, :length => {:minimum => 8, :maximum => 11, :message => "联系电话必须大于8位小于11位！", :allow_blank => true}


  validate :validate_start_time_end_time

  def validate_start_time_end_time
    self.errors.add(:base, "开始时间应小于结束时间") if self.start_time >= self.end_time 
  end

  def generate_court_period_price(period_price)
    self.court_period_prices.find_all_by_period_price_id(period_price.id).first
  end

  def can_not_book_now?(date, hour)
    Setting.can_book_time_before_book.from_now < date + hour
  end

  def can_be_book?(date, hour)
    @book_records ||= book_records.where(["alloc_date=?", date])
    @book_records.detect do |element|
      element.alloc_date == date && element.start_hour < hour && element.end_hour > hour
    end.blank?
  end

  def book_record_start_at(date, start_hour)
    @book_records ||= book_records.where(["alloc_date=?", date])
    @book_records.detect { |element| element.start_hour == start_hour && element.alloc_date == date}
  end

  def daily_book_records(date = Date.today)
    book_records.where(:alloc_date => date)
  end

  def is_useable_in_time_span?(period_price)
    @period_prices ||= period_prices
    (@period_prices & period_price).present?
  end

  def daily_period_prices(date = Date.today)
    court_available_period_prices = []
    period_prices = PeriodPrice.all_periods_in_time_span(date, start_hour, end_hour)
    period_prices.each do |period_price |
      court_available_period_prices << period_price  if is_useable_in_time_span?(date)
    end
    court_available_period_prices.sort{|fst,scd| fst.start_time <=> scd.start_time }
  end


  def calculate_amount_in_time_span(date, start_hour, end_hour)
    PeriodPrice.calculate_amount_in_time_spans(date, start_hour, end_hour) do |period_price|
      court_period_price = court_period_prices.where("period_price_id=#{period_price.id}").first
      [!court_period_price.nil? ,court_period_price.try(:court_price) || 0]
    end
  end

  def amount(order_item)
    calculate_amount_in_time_span(order_item.order_date,order_item.start_hour,order_item.end_hour)
  end

  def start_hour(date=Date.today)
    perod_prices = daily_period_prices(date)
    perod_prices.blank? ? 0 : perod_prices.first.start_time
  end

  def period_prices_by_date(date)
    period_prices.select{|pp| pp.is_fit_for?(date)}.sort{|a, b| a.start_time <=> b.start_time}
  end

  def open_hours_range(date = Date.today)
    pps = period_prices_by_date(date)
    pps.first.start_time..pps.last.end_time
  end

  def end_hour(date=Date.today)
    perod_prices = daily_period_prices(date)
    perod_prices.blank? ? 0 : perod_prices.last.end_time
  end

  def period_prices_in_time_span(date, start_hour, end_hour)
    self.period_prices.select { |element|
      element.is_fit_for?(date) and ((element.start_time..element.end_time).to_a & (start_hour..end_hour).to_a).present? 
    }
  end

end
