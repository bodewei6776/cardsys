module NonMemberOrder

  def order_errors
    @order_errors ||= []
  end

  def clear_order_errors
    order_errors.clear
  end

  def is_ready_to_order?(order)
    clear_order_errors
    book_record = order.book_record
    date,start_hour,end_hour = book_record.record_date,book_record.start_hour,book_record.end_hour
    court_amount = book_record.court.calculate_amount_in_time_span(date,start_hour,end_hour)
   # if earnest.blank? || earnest.to_i < court_amount
   #   order_errors << I18n.t('order_msg.non_member.earnest_not_enougth')
   # end
  end
  
end
