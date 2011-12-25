class CourtBookRecord < BookRecord
  def court
    resource
  end

  def price
    court.calculate_amount_in_time_span(alloc_date, start_hour, end_hour)
  end

  def description
    court.name + "(" + alloc_date.strftime("%Y-%m-%d  ") + start_hour.to_s + ":00 - " + end_hour.to_s + ":00" + ")"
  end

end
