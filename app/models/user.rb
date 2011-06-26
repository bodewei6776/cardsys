require 'pinyin/pinyin'
class User < ActiveRecord::Base

  has_many :department_users
  has_many :departments,:through => :department_users
  acts_as_authentic do |c|
    c.validates_length_of_password_confirmation_field_options = {:minimum => 1 }# if c.password.present?
    c.validates_length_of_password_field_options = { :minimum => 1 }# if c.password_confirmation.present?
    c.merge_validates_length_of_password_field_options :message => "密码过短"
    c.merge_validates_length_of_password_confirmation_field_options :message => "密码过短"
    c.validates_length_of_login_field_options = {:within => 0..100}
    c.merge_validates_length_of_login_field_options :message => '登录名长度过短'
  end

  has_many   :user_powers
  has_many :powers,:through => :user_powers,:conditions => "will_show = 1"
  has_and_belongs_to_many :catenas

  #  validates :login, :presence => {:message => "用户名不能为空！"},
  # :uniqueness => {:on => :create, :message => '用户名已经存在！', :if => Proc.new { |user| !user.login.nil? && !user.login.blank? }}
  #  validates :password, :presence => {:message => "密码不能为空！"}
  #  validates :user_name, :presence => {:message => "昵称不能为空！"}

  belongs_to :catena
  before_save :geneate_name_pinyin

  def geneate_name_pinyin
    pinyin = PinYin.new
    self.user_name_pinyin = pinyin.to_pinyin(self.user_name) if self.user_name
  end


  def should_catena?
    false
  end

  def can_catena?
    false
  end


  after_create :set_powers

  def set_powers
    self.powers = self.departments ? self.departments.collect(&:powers).flatten : []
    self.save
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


  def department_powers
    self.departments.collect(&:powers).flatten.uniq rescue []
  end
  def menus
    self.powers.collect(&:subject)
  end

  def can_book_when_time_due?
    self.menus.include?("过期预定")
  end

  def can?(action)
    self.menus.include?(action)
  end

end
