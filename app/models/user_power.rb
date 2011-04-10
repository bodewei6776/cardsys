class UserPower < ActiveRecord::Base
  belongs_to :user
  belongs_to :power

  #default_scope where({:catena_id => current_catena.id})

end
