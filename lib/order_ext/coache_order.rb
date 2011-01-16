module CoacheOrder

  def order_errors
    @order_errors ||= []
  end

  def clear_order_errors
    order_errors.clear
  end

  def is_ready_to_order?(order)
    clear_order_errors
    unless (exist_coaches = coache_items_in_time_span(order)).blank?
      order_errors << I18n.t('order_msg.coache.conflict',:coach_name => exist_coaches.map(&:product).map(&:name).join(','),
      :start_hour => order.start_hour,:end_hour => order.end_hour)
    end
  end

  private
  def coache_items_in_time_span(order)
    OrderItem.coache_items_in_time_span(order)
  end
    
end
