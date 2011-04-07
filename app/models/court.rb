class Court < ActiveRecord::Base

  has_many :court_period_prices
  has_many :book_records

  scope :search_order, order("id")

  
  validates :name, :presence => {:message => "场地名称不能为空！"}
  validates :name, :uniqueness => {:on => :create, :message => '场地名称已经存在了！', :if => Proc.new { |court| !court.name.nil? && !court.name.blank? }}
  validates :telephone, :numericality => {:only_integer => true, :message => "电话号码必须为数字！", :allow_blank => true}, :length => {:minimum => 8, :maximum => 11, :message => "联系电话必须大于8位小于11位！", :allow_blank => true}


  Status_Free = 1
  Status_Disable = 2

  scope :enabled,where(:status => Status_Free)
  def generate_court_period_price(period_price)
    self.court_period_prices.find_all_by_period_price_id(period_price.id).first
  end

  def daily_book_records(date = Date.today)
    BookRecord.daily_book_records(date).court_book_records(self.id)
  end

  def is_useable_in_time_span?(period_price)
    !court_period_prices.where("period_price_id=#{period_price.id}").first.nil?
  end

  def daily_period_prices(date=Date.today,start_hour = nil,end_hour = nil)
    court_available_period_prices = []
    period_prices = PeriodPrice.all_periods_in_time_span(date, start_hour, end_hour)
    period_prices.each do |period_price |
      court_available_period_prices << period_price  if(is_useable_in_time_span?(period_price))
    end
    court_available_period_prices.sort{|fst,scd| fst.start_time <=> scd.start_time }
  end

  def calculate_amount_in_time_span(date,start_hour,end_hour)
    PeriodPrice.calculate_amount_in_time_spans(date,start_hour,end_hour) do |period_price|
      court_period_price = court_period_prices.where("period_price_id=#{period_price.id}").first
      [!court_period_price.nil? ,court_period_price.court_price]
    end
  end
  
  def amount(order_item)
    calculate_amount_in_time_span(order_item.order_date,order_item.start_hour,order_item.end_hour)
  end
  
  def start_hour(date=Date.today)
    perod_prices = daily_period_prices(date)
    perod_prices.blank? ? 0 : perod_prices.first.start_time
  end
  
  def end_hour(date=Date.today)
    perod_prices = daily_period_prices(date)
    perod_prices.blank? ? 0 : perod_prices.last.end_time
  end
  
end
