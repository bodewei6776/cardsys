class Vacation < ActiveRecord::Base

  validates :name, :presence => {:message => "名称不能为空！"}
  validates :name, :uniqueness => {:on => :create, :message => '名称已经存在！', :if => Proc.new { |vacation| !vacation.name.nil? && !vacation.name.blank? }}
  validates :start_date, :presence => {:message => "开始日期不能为空！"}
  validates :end_date, :presence => {:message => "结束日期不能为空！"}
  validates :start_date, :uniqueness => {:on => :create, :message => '开始日期已经存在！'}
  validates :end_date, :uniqueness => {:on => :create, :message => '结束日期已经存在！'}

  def is_holiday?
    status == CommonResource::IS_HOLIDAY
  end

  def is_daily?
    status == CommonResource::IS_DAILY
  end
  
end
