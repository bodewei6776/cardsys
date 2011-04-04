class MemberCardGranter < ActiveRecord::Base
  belongs_to :member
  belongs_to :member_card

#  #default_scope where({:catena_id => current_catena.id})
end
