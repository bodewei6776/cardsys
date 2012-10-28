class CustomDateForReport
  def initialize(date, accounting_begin_day = 1)
    @date = date
    @accounting_begin_day = accounting_begin_day
  end

  def beginning_of_month
    ((@date - 1.month).beginning_of_month + @accounting_begin_day.days)
  end

  def end_of_month
    (@date.beginning_of_month + (@accounting_begin_day - 1).days)
  end

  def each_day_of_this_financial_month(&block)
    (self.beginning_of_month..self.end_of_month).each &block
  end
end
