# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  include HasPinyinColumn
  include HashColumnState
  set_pinyin_field :user_name_pinyin, :user_name

  has_many :department_users
  has_many :departments, :through => :department_users

  acts_as_authentic do |c|
    c.merge_validates_length_of_login_field_options(:allow_blank => true, :message => "登陆名长度")
    c.merge_validates_format_of_login_field_options(:allow_blank => true)
    c.merge_validates_length_of_password_field_options(:allow_blank => true, :message => "长度太短")
    c.merge_validates_length_of_password_confirmation_field_options(:allow_blank => true, :message => "长度太短")
  end

  def powers
    self.departments.collect(&:powers).flatten.uniq
  end

  def admin?
    self.login == 'admin'
  end

  def menus
    (self.departments.collect(&:powers).flatten).uniq.collect(&:subject)
  end

  def can_book_when_time_due?
    self.menus.include?("过期预定")
  end

  def can?(action)
    self.menus.include?(action)
  end


  def departments_names
    self.departments.collect(&:name).join(", ")
  end

  def  can_destroy?
   false 
  end
end
