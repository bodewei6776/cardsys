class MemberCardGranter < ActiveRecord::Base
  belongs_to :member
  belongs_to :granter,:class_name => "Member",:foreign_key => "granter_id"
  belongs_to :members_card, :foreign_key => "member_card_id"
end
