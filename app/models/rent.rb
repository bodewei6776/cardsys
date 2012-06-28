# -*- encoding : utf-8 -*-
class Rent < ActiveRecord::Base
  include Authenticateable
  belongs_to :locker
  belongs_to :members_card,:foreign_key => :card_id
  belongs_to :member

  HUMAN_NAME = {
    "start_date" => "起租时间",
    "end_date"   => "退租时间",
    "total_fee"  => "租用费用"
  }

  delegate :num, :state_desc, :to => :locker

  attr_accessor :card_num,:password,:user_name

  [:locker_id, :start_date, :end_date, :total_fee].each do |c|
    validates_presence_of c, :message => "#{HUMAN_NAME[c.to_s]}不能为空" 
  end

  [:member_name,:card_num].each do |c|
    #validates_presence_of c, :message => "#{c.to_s}不能为空" if Proc.new {|o| o.is_member?  }
  end

  validates_numericality_of :total_fee, :greater_than_or_equal_to => 0, :allow_nil => true

  validate do |rent|
    self.errors.add(:base,"开始时间应该小于结束时间") if rent.start_date && rent.end_date && \
      rent.start_date > rent.end_date
  end


  before_validation do |rent|
    self.validate_in_condition_needed = true
  end

  before_create do
    self.rent_state = "enable"
  end

  after_create do 
    self.locker.update_attribute(:state, "rented")
  end


  def rent_member_name
   is_member? ? member.name : member_name 
  end

  def almost_due?(date = Date.today)
    CommonResource.locker_due_time.days.from_now > self.end_date && date < self.end_date
  end

  def pay
    true
  end

  def expire?(date = Date.today)
    date > self.end_date
  end

    
end
