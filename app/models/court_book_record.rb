# -*- encoding : utf-8 -*-
class CourtBookRecord < BookRecord
  def court
    resource
  end

  def price(members_card = nil)
    members_card.present? ? members_card.card.total_money_in_time_span(self, alloc_date, start_hour, end_hour) : court.calculate_amount_in_time_span(alloc_date, start_hour, end_hour)
  end

  def description
    court.name + "(" + alloc_date.strftime("%Y-%m-%d  ") + start_hour.to_s + ":00 - " + end_hour.to_s + ":00" + ")"
  end

  def period_prices
    court.period_prices_in_time_span(alloc_date, start_hour, end_hour)
  end

end
