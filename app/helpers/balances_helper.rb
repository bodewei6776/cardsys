module BalancesHelper
  
  def display_order_amount
  end

  def balance_time_span_in_word(balance)
    book_record = balance.order.book_record
    day_names=%w{ 星期一 星期二 星期三 星期四 星期五 星期六 星期日}

    book_record.start_hour.to_s + ":00-" + book_record.end_hour.to_s + ":00" + "  " +
      book_record.record_date.strftime("%Y-%m-%d   " ) +
      day_names[book_record.record_date.strftime("%w").to_i - 1]
      
  end
  
end
