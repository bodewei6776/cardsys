# -*- encoding : utf-8 -*-
class Category < ActiveRecord::Base
  has_many :goods,:foreign_key => "good_type"
  acts_as_tree :order => "position"
  validate :category_stack_should_not_too_deep
  validates_presence_of :name

  def all_goods
    parent_id.present? ? goods : Good.where(["good_type in (?)", children.collect(&:id)])
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

  def can_destroy?
    !self.children.present? && !self.goods.present?
  end

  class << self
    def roots_b
      find(:all,:conditions => {:parent_id => 0},:order => "position")
    end
  end
end
