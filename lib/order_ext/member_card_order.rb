module MemberCardOrder
  
  def order_errors
    @order_errors ||= []
  end

  def clear_order_errors
    order_errors.clear
  end

  def is_ready_to_order?(order)
    clear_order_errors
    has_enough_amount_to_order?(order)
    should_order_in_time_span?(order)
    is_status_ready_to_order?
  end

  private
  def has_enough_amount_to_order?(order)
    #TODO
    true
  end

  def should_order_in_time_span?(order)
    unless is_useable_in_time_span?(order.book_record)
      book_record = order.book_record
      unusable_time_spans = card.unuseable_time_spans(book_record.record_date,book_record.start_hour,book_record.end_hour)
      unsuable_span_info = unusable_time_spans.map{|s,e|"#{s}:00-#{e}:00"}.join(';')
      order_errors << I18n.t('order_msg.member_card.invalid_time_span',:unusable_span => unsuable_span_info)
    end
  end

  def is_status_ready_to_order?
    order_errors << I18n.t('order_msg.member_card.expired') if is_expired?
    order_errors << I18n.t('order_msg.member_card.notavalible') unless is_avalible?
  end

end
