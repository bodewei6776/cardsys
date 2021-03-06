# -*- encoding : utf-8 -*-
class Power < ActiveRecord::Base
  has_many   :user_powers,:dependent => :destroy
  has_many :users,:through => :user_powers
  has_many   :department_powers,:dependent => :destroy
  has_many :children, :class_name => "Power", :foreign_key => :parent_id
  scope :tops, lambda { {:conditions =>  "parent_id = 0" }}

  after_create do |p| p.update_attribute(:will_show , true) end

  def self.all
    where(:will_show => true)
  end

  def self.all_with_hide
    where(["will_show = ? or will_show =? or will_show is ?",true,false,nil])
  end

  def children_without_hide
    self.children.where(:will_show => true)
  end

  def self.tree_top
    where(:parent_id => 0, :will_show => true)
  end

  def self.all_tree_top
    where(:parent_id => 0)
  end

  def show!
    self.update_attribute(:will_show,true)
  end

  def hide!
    self.update_attribute(:will_show,false)
  end

  def can_destroy?
    
    false
  end


end
