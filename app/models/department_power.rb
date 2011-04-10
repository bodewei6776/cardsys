class DepartmentPower < ActiveRecord::Base

  belongs_to :department
  belongs_to :power
  #default_scope where({:catena_id => current_catena.id})
end
