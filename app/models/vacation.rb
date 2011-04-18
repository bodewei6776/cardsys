class Vacation < ActiveRecord::Base

  validates :name, :presence => {:message => "名称不能为空！"}
  validates :name, :uniqueness => {:on => :create, :message => '名称已经存在！', :if => Proc.new { |vacation| !vacation.name.nil? && !vacation.name.blank? }}
  validates :start_date, :presence => {:message => "开始日期不能为空！"}
  validates :end_date, :presence => {:message => "结束日期不能为空！"}
  validates :start_date, :uniqueness => {:on => :create, :message => '开始日期已经存在！'}
  validates :end_date, :uniqueness => {:on => :create, :message => '结束日期已经存在！'}

  validate :start_date_should_be_after_now
  validate :end_date_should_be_after_now
  validate :should_not_duplicate_with_other_time_span

  def should_not_duplicate_with_other_time_span
    self.errors.add(:base,"时间段冲突了") if self.class.exists?(["(start_date < :end_date and :end_date < end_date) or (start_date < :start_date and :start_date < end_date)",{:start_date => start_date,:end_date => end_date}])
  end

  def start_date_should_be_after_now
    self.errors.add(:start_date,"开始时间过了，　别修改啦") if self.start_date < Time.now
  end

  def end_date_should_be_after_now
    self.errors.add(:end_date,"结束时间过了，　别修改啦") if self.start_date < Time.now
  end

  def is_holiday?
    status == CommonResource::IS_HOLIDAY
  end

  def is_daily?
    status == CommonResource::IS_DAILY
  end

  def can_edit?
    self.start_date > Time.now and self.end_date > Time.now
  end
  
end
