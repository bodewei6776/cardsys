# -*- encoding : utf-8 -*-
class UserPower < ActiveRecord::Base
  belongs_to :user
  belongs_to :power
end
