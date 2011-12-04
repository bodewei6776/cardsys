class Price
  attr_accessor :money_price, :count_price, :single_money_price, :single_count_price

  def initialize(quantity, options = nil)
    options ||= {}
    @single_money_price = options[:single_money_price] || 0
    @single_count_price = options[:single_count_price] || 0

    @money_price = options[:money_price] || 0 
    @count_price = options[:count_price] || 0
  end

  def +(other)
    self.money_price += other.money_price
    self.count_price += other.count_price
  end

  def *(quantity)
    @money_price = quantity * @single_money_price
    @count_price = quantity * @single_count_price
  end

  def to_hash
    {:money_price => @money_price, :count_price => @count_price, :single_money_price => @single_money_price}
  end

  def total_price
    @money_price
  end
end
