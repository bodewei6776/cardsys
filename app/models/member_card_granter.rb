class MemberCardGranter < ActiveRecord::Base
  belongs_to :member
  belongs_to :granter,:class_name => "Member",:foreign_key => "granter_id"
  belongs_to :member_card

  def disable!
    self.state = "disabled"
    self.save!
  end

  def disabled?
    self.state == "disabled"
  end

  def enabled?
    self.state == "enabled"
  end

  def enable!
    self.state = "enabled"
    self.save!
  end
end
