class Power < ActiveRecord::Base
  has_many   :user_powers
  has_and_belongs_to_many :users
  has_many   :department_powers

  #default_scope where(:will_show  => true)
  #scope :all,where(:will_show => true)
  #:scope :all_include_hide,all

  def self.all
    where(:will_show => true)
  end

  def self.all_with_hide
    where(["will_show = ? or will_show =? or will_show is ?",true,false,nil])
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


end
