
class LI
  attr_accessor :product_id,:quantity

  def to_s
    "<quantity #{self.quantity},product_id #{self.product_id}"
  end

  def initialize(product_id,quantity)
    quantity = quantity.abs
    self.product_id,self.quantity = product_id,quantity
  end

  def product
    Good.find(self.product_id)
  end

  # 单价  计算后的价格, 应该考虑到团购后的打折信息 或者赠品
  def price
    self.product.price
  end
  def sub_total_price
    self.quantity * self.price
  end
end
class Cart
  attr_accessor :line_items

  def initialize
    @line_items = []
  end

  def to_s
    self.line_items.collect(&:to_s).join(",")
  end
  def add(product_id,quantity)
    quantity = quantity.abs
    li = line_items.select {|li| li.product_id == product_id}.first
    actual_quantity = quantity
    if li
      actual_quantity =  li.quantity + quantity
    end
    self.remove(product_id)
    @line_items << LI.new(product_id,actual_quantity)
  end

  def remove(product_id)
    @line_items.delete_if{|li| li.product_id == product_id}
  end

  def total_price
    self.line_items.sum(&:sub_total_price)
  end

  def total_quantity
    self.line_items.sum(&:quantity)
  end

  def blank?
    @line_items.blank?
  end

end


