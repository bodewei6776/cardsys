class Rent < ActiveRecord::Base
  belongs_to :locker
  belongs_to :member_card,:foreign_key => :card_id
  belongs_to :member

  attr_accessor :member_name,:card_num,:password,:user_name
  [:locker_id,:member_name,:card_num,:start_date,:end_date,:total_fee,:pay_way].each do |c|
    validates_presence_of c, :message => "#{c.to_s}不能为空"
  end

  validate do |rent|
    self.errors.add(:base,"开始时间应该小于结束时间") if rent.start_date && rent.end_date && \
      rent.start_date >= rent.end_date
  end


  before_save do |rent|
    rent.card_id = self.card_num
    rent.member_id = Member.find_by_name(self.member_name).id
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
