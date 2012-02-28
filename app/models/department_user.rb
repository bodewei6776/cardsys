# -*- encoding : utf-8 -*-
class DepartmentUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :department
end
