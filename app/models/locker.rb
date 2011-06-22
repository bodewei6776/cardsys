class Locker < ActiveRecord::Base

  LOCKER_STATE = {:empty => "未使用",:rented => "出租中"}
  validates :num,:presence => true

  has_many :rents,:dependent => :destroy
 # has_one :current_rent,:conditions => ["start_date < ? and end_date > ?",Time.now.to_s(:db),Time.now.to_s(:db)]
  #
  #
  validate :num,:state,:locker_type ,:presence => true,:message => "{column}以上字段不能空"

  scope :rented,where({:state => :rented }) 
  
  def current_rent(date = Date.today)
    self.rents.select {|r| r.start_date.to_date <= date && date <= r.end_date.to_date }.first
  end

  def locker_type_in_word
    CommonResourceDetail.find(self.locker_type).detail_name rescue "未知"
  end
  


  before_create do |record|
   record.state = "empty"
  end

  before_create :generate_num

  def self.next_num
    num = Locker.last.try("num").presence || "BH0000"
    num.succ
  end

  def color(date = Date.today)
    puts self.state_at(date)
    case self.state_at(date)
    when "empty" 
      "green"
    when "rented" 
      "purple"
    when  "almost_due"
      "#933"
    end
  end

  def state_in_words(date = Date.today)
    case self.state_at(date)
    when "empty" 
      "未占用"
    when "rented" 
      "使用中"
    when "almost_due"
      "即将到期"
    end
  end

  def almost_due?(date)
    self.state == "rented" && self.current_rent && self.current_rent.almost_due?(date)
  end

  def state_at(date)
    if self.current_rent(date).present?
      if self.current_rent(date).almost_due?
        "almost_due" 
      else
        "rented"
      end
    else
      "empty"
    end
  end

  def rented?
    self.current_rent.present?
  end

  def generate_num
    self.num = self.class.generate_num
  end

  def generate_num
  end
end
