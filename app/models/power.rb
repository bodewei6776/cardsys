class Power < ActiveRecord::Base
  has_many   :user_powers
  has_and_belongs_to_many :users
  has_many   :department_powers

  acts_as_tree

end
