# -*- encoding : utf-8 -*-
class Locker < ActiveRecord::Base

  LOCKER_STATE = {:empty => "未使用",:rented => "出租中"}
  validates :num,:presence => true

  has_many :rents,:dependent => :destroy
  validate :num,:state,:locker_type ,:presence => true,:message => "{column}以上字段不能空"

  def current_rent(date = Date.today)
    self.rents.select {|r| r.rent_state == "enable" }.first
  end

  def locker_type_in_words
    CommonResourceDetail.find_by_id(self.locker_type).try(:detail_name) || "未知"
  end

  before_create :generate_num

  def self.next_num
    num = Locker.last.try("num").presence || "BH0000"
    num.succ
  end

  def style(date = Date.today)
    self.state_at(date)
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
    self.current_rent && self.current_rent.almost_due?(date)
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


  def state_desc
    self.state_in_words
  end

  def locker_state_in_words 
    Locker::LOCKER_STATE[state.intern] rescue "未知"
  end

  def respond_to? a
    if a == :state
      false
    else
      super a
    end
  end

  def can_view?
    false
    
  end
end
