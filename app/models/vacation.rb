# -*- encoding : utf-8 -*-
class Vacation < ActiveRecord::Base

  VACATION_TYPE_MAP = {"holiday" => "节假日", "workday" => "工作日"}

  validates :name, :presence => {:message => "名称不能为空！"}
  validates :name, :uniqueness => {:on => :create, :message => '名称已经存在！', :if => Proc.new { |vacation| !vacation.name.nil? && !vacation.name.blank? }}
  validates :start_date, :presence => {:message => "开始日期不能为空！"}
  validates :end_date, :presence => {:message => "结束日期不能为空！"}
  validates :start_date, :uniqueness => {:on => :create, :message => '开始日期已经存在！'}
  validates :end_date, :uniqueness => {:on => :create, :message => '结束日期已经存在！'}

  validate :start_date_should_be_after_now
  validate :end_date_should_be_after_now
  validate :end_date_should_be_start_date
  validate :should_not_duplicate_with_other_time_span
  def should_not_duplicate_with_other_time_span
    self.errors.add(:base,"时间段冲突了") if self.class.exists?(["((start_date < :end_date and :end_date < end_date) or
                                                                       (start_date < :start_date and :start_date < end_date)) AND :vacation_type",{:start_date => start_date,:end_date => end_date, :vacation_type => :vacation_type}])
  end


  def start_date_should_be_after_now
    return true if self.start_date.nil?
    self.errors.add(:start_date,"开始时间过了，　别修改啦") if self.start_date < Date.today
  end

  def end_date_should_be_after_now
    return true if self.end_date.nil?
    self.errors.add(:end_date,"结束时间过了，　别修改啦") if self.end_date < Date.today
  end


  def end_date_should_be_start_date
    self.errors.add(:end_date,"结束时间需要大于/等于开始时间") if self.end_date < self.start_date
  end

  def can_edit?
    false
  end
  
  def can_view?
    false
  end

  def is_holiday?
    self.vacation_type == "holiday"
  end

  def is_workday?
    self.vacation_type == "workday"
  end

  def vacation_type_in_word
    VACATION_TYPE_MAP[self.vacation_type]
  end
end
