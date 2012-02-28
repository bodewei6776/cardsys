# -*- encoding : utf-8 -*-
module LockersHelper
  def locker_type_in_words(type)
    CommonResourceDetail.find(type).detail_name rescue "未知"
  end

  def locker_state_in_words state
    Locker::LOCKER_STATE[state.intern] rescue "未知"
  end
end
