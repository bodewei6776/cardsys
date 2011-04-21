class Power < ActiveRecord::Base
  has_many   :user_powers,:dependent => :destroy
  has_many :users,:through => :user_powers
  has_many   :department_powers,:dependent => :destroy

  #default_scope where(:will_show  => true)
  #scope :all,where(:will_show => true)
  #:scope :all_include_hide,all

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

  acts_as_tree

  def self.tree_top
    where(:parent_id => 0,:will_show => true)
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


end
