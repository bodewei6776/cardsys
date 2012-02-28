# -*- encoding : utf-8 -*-
class DepartmentPower < ActiveRecord::Base
  belongs_to :department
  belongs_to :power
end
