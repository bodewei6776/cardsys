class RechargeRecord < ActiveRecord::Base
  belongs_to :member_card
  belongs_to :member
end
