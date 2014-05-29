class CustomDateForReport
  def initialize(date, accounting_begin_day = 0)
    @date = date
    @accounting_begin_day = accounting_begin_day
  end

  def beginning_of_month
    if @accounting_begin_day > 14
      ((@date - 1.month).beginning_of_month + @accounting_begin_day.days)
    else
      (@date.beginning_of_month + @accounting_begin_day.days)
    end
  end

  def end_of_month
    if @accounting_begin_day > 14
      (@date.beginning_of_month + (@accounting_begin_day - 1).days)
    else
      ((@date + 1.month) + (@accounting_begin_day - 1).days)
    end
  end

  def each_day_of_this_financial_month(&block)
    (self.beginning_of_month..self.end_of_month).each &block
  end
end
