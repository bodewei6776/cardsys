class ActiveRecord::Base
  def can_view?
    false
  end
  def can_destroy?
    true
  end


  def can_edit?
    true
  end
end
