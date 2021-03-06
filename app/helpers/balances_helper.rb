# -*- encoding : utf-8 -*-
module BalancesHelper
  
  def display_order_amount
  end

  def balance_time_span_in_word(balance)
    book_record = balance.order.court_book_record
    day_names=%w{ 星期一 星期二 星期三 星期四 星期五 星期六 星期日}

    book_record.start_hour.to_s + ":00-" + book_record.end_hour.to_s + ":00" + "  " +
      book_record.alloc_date.strftime("%Y-%m-%d   " ) +
      day_names[book_record.alloc_date.strftime("%w").to_i - 1]
      
  end

  def discount_options(selected)
    options = ""
    options << "<option value='1'>无折扣</option>"
    (1..9).to_a.reverse_each do |i|
      discount = (i/10.0).to_f;
    options << "<option value='#{ discount }' #{"selected" if discount == selected.to_f }>#{i}折</option>"
    end
    options
  end
  
end
