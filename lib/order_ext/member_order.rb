module MemberOrder
  
  def order_errors
    @order_errors ||= []
  end

  def clear_order_errors
    order_errors.clear
  end
  
  def is_ready_to_order?(order)
    clear_order_errors
    unless has_card?
      order_errors << I18n.t('order_msg.member.non_card')
    end
  end
  
end
