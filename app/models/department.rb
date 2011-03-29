class Department < ActiveRecord::Base
  validates :name, :presence => {:message => "名称不能为空！"}
  validates :name, :uniqueness => { :message => '名称已经存在了！'}


  has_many  :users
  has_many  :powers

  #default_scope where({:catena_id => current_catena.id})

  before_create :set_catena_id

  def set_catena_id
    self.catena_id = current_catena.id
  end

  def has_power? power
    !DepartmentPower.where(:power_id => power.id).where(:department_id => self.id).first.nil?
  end
end
