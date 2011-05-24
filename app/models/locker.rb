class Locker < ActiveRecord::Base

  LOCKER_STATE = {:empty => "未使用",:rented => "出租中"}

  validates :num,:presence => true




  before_create do |record|
   record.state = "empty"
  end

  before_create :generate_num

  def self.next_num
    num = Locker.last.try("num").presence || "BH0000"
    num.succ
  end

  def rented?
  end

  def generate_num
    self.num = self.class.generate_num
  end

  def generate_num
  end
end
