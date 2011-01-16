class User < ActiveRecord::Base

  acts_as_authentic

  belongs_to :department
  has_many   :user_powers
#  has_and_belongs_to_many :powers   #some error when user.save
  
#  validates :login, :presence => {:message => "用户名不能为空！"},
# :uniqueness => {:on => :create, :message => '用户名已经存在！', :if => Proc.new { |user| !user.login.nil? && !user.login.blank? }}
#  validates :password, :presence => {:message => "密码不能为空！"}
#  validates :user_name, :presence => {:message => "昵称不能为空！"}

  before_create :set_catena_id

  def set_catena_id
    self.catena_id = current_catena.id
  end
  
  def is_admin?
    self.login == 'admin'
  end

  #TODO
  def can?(action_name, subject)
#    return true
    #return true if is_admin?
    #self.roles.include?{|role| role.action == action_name && role.subject == subject }
    flag = false
#    p_ids = []
#    UserPower.where(:user_id => self.id).each do  |i|
#      p_ids << i.power_id
#    end
#    Power.where(["id in (?)", p_ids]).each do |u_power|
#      if u_power.action.eql?(subject + "_" + action_name)
#        return true
#      end
#    end
    return flag
  end

  def has_power? power
    !UserPower.where(:power_id => power.id).where(:user_id => self.id).first.nil?
  end

end
