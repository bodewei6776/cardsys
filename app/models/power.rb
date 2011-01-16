class Power < ActiveRecord::Base
  has_many   :user_powers
  has_and_belongs_to_many :users

  has_many   :department_powers

  #default_scope where({:catena_id => current_catena.id})

  before_create :set_catena_id

  def set_catena_id
    self.catena_id = current_catena.id
  end
end
