class Rent < ActiveRecord::Base
  belongs_to :locker
  belongs_to :member_card,:foreign_key => :card_id
  belongs_to :member
  

  def pay
    self.card_id = self.card_num
    self.member_id = Member.find_by_name(self.member_name).id rescue nil

    if self.pay_way ==Balance::Balance_Way_Use_Card && member_card.nil?
      self.errors.add(:base,"会员卡不存在") and return false
    end 

    if self.pay_way == Balance::Balance_Way_Use_Card && member_card.left_fee < self.total_fee
      self.errors.add(:base,"卡内余额不足") and return false
    end

    if self.pay_way == Balance::Balance_Way_Use_Card
      member_card.update_attribute(:left_fee,member_card.left_fee -= self.total_fee)
    end
    true
  end

  attr_accessor :card_num,:password,:user_name

  [:locker_id,:start_date,:end_date,:total_fee,:pay_way].each do |c|
    validates_presence_of c, :message => "#{c.to_s}不能为空" 
  end

  [:member_name,:card_num].each do |c|
    #validates_presence_of c, :message => "#{c.to_s}不能为空" if Proc.new {|o| o.is_member?  }
  end

  validates_numericality_of :total_fee,:only_integer => true,:greater_than_or_equal_to => 0

  validate do |rent|
    self.errors.add(:base,"开始时间应该小于结束时间") if rent.start_date && rent.end_date && \
      rent.start_date >= rent.end_date
  end


  before_validation do |rent|
    rent.card_id = self.card_num
    rent.member_id = Member.find_by_name(self.member_name).id rescue nil
  end

  after_create do 
    self.locker.update_attribute(:state,"rented")
  end



  def almost_due?(date = Date.today)
    CommonResource.locker_due_time.days.from_now > self.end_date && date < self.end_date
  end

  def expire?(date = Date.today)
    date > self.end_date
  end
end
