class CourtBookRecord < BookRecord
  def court
    resource
  end

  def price
    court.calculate_amount_in_time_span(alloc_date, start_hour, end_hour)
  end

end
