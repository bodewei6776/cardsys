class Department < ActiveRecord::Base
  validates :name, :presence => {:message => "名称不能为空！"}
  validates :name, :uniqueness => { :message => '名称已经存在了！'}

  has_many :department_users
  has_many  :users,:through => :department_users
  has_many :department_powers
  has_many  :powers,:through => :department_powers

  def has_power? power
    self.powers and self.powers.include?(power)
  end
end
