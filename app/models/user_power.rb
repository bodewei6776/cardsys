class UserPower < ActiveRecord::Base
  belongs_to :user
  belongs_to :power
end
