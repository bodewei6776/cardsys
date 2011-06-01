class Category < ActiveRecord::Base
  has_many :goods,:foreign_key => "good_type"
 # has_many :all_goods,:foreign_key => "good_type",:class_name => "Good",
 #   :through => :children,:source => :goods
  acts_as_tree :order => "position"
  validate :category_stack_should_not_too_deep

  def all_goods
    if self.parent_id
      self.goods
    else
      Good.where(["good_type in (?)",self.children.collect(&:id)])
    end
  end
  

  def category_stack_should_not_too_deep
    self.errors.add(:base,"分类层级不能超过两层")  if self.has_grantpa?
  end

  def has_grantpa?
    begin
      self.parent.parent
    rescue
      return false
    end
  end

  class << self
    def roots_b
      find(:all,:conditions => {:parent_id => 0},:order => "position")
    end
  end
end
