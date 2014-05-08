
module ExpireFragmentCache
  def expire_order(order)
    book_record = order.court_book_record
    return true unless book_record

    ac = ActionController::Base.new
    ac.expire_fragment("#{book_record.alloc_date}_#{book_record.start_hour - 1}_#{book_record.court.id}")
    ac.expire_fragment("#{book_record.alloc_date}_#{book_record.start_hour}_#{book_record.court.id}")
    ac.expire_fragment("#{book_record.alloc_date}_#{book_record.start_hour + 1}_#{book_record.court.id}")
  end

  def expire_with_date_time_and_court(date, start_hour, court)
    ac = ActionController::Base.new
    ac.expire_fragment("#{date}_#{start_hour + 1}_#{court.id}")
  end
end
