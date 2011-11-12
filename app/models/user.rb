require 'pinyin/pinyin'
class User < ActiveRecord::Base

  has_many :department_users
  has_many :departments,:through => :department_users
  acts_as_authentic do |c|
    c.merge_validates_length_of_login_field_options(:allow_blank => true)
    c.merge_validates_format_of_login_field_options(:allow_blank => true)
    c.merge_validates_length_of_password_field_options(:allow_blank => true)
    c.merge_validates_length_of_password_confirmation_field_options(:allow_blank => true)
  end

  has_many   :user_powers
  has_many :powers,:through => :user_powers

  before_save :geneate_name_pinyin, :set_powers

  def geneate_name_pinyin
    pinyin = PinYin.new
    self.user_name_pinyin = pinyin.to_pinyin(self.user_name) if self.user_name
  end



  def set_powers
    return true unless self.departments
    self.powers = self.departments.collect(&:powers).flatten
  end


  def is_admin?
    self.login == 'admin'
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
