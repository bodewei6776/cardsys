
class LI
  attr_accessor :product_id,:quantity,:real_total_price,:discount

  def to_s
    "<quantity #{self.quantity},product_id #{self.product_id}"
  end

  def initialize(product_id,quantity)
    quantity = quantity.abs
    self.product_id,self.quantity = product_id,quantity
    self.real_total_price = self.sub_total_price
    self.discount = 1
  end

  def product
    @product ||= Good.find(self.product_id)
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

  def destock(product_id,count)
    g = Good.find(product_id)
    g.count_front_stock_out +=  count
    g.count_front_stock -=  count
    g.save
  end

  def restock(product_id)
    li = @line_items.find{|li| li.product_id == product_id}
    g = Good.find(product_id)
    g.count_front_stock_out -= li.quantity.to_i
    g.count_front_stock += li.quantity.to_i
    g.save
  end

  def change_li_real_total_price(product_id,real_total_price,discount)
    li = @line_items.find{|li| li.product_id == product_id}
    li.real_total_price = real_total_price.to_f
    li.discount = discount
  end

  def remove(product_id)
    @line_items.delete_if{|li| li.product_id == product_id}
  end

  def total_price
    self.line_items.sum(&:real_total_price) rescue self.line_items(&:sub_total_price)
  end

  def total_quantity
    self.line_items.sum(&:quantity)
  end

  def blank?
    @line_items.blank?
  end

  def products
    self.line_items.collect(&:product)
  end

  def empty!
    self.line_items = []
  end

  def touch
    self.line_items.each do |li|
      li.product.order_count = li.quantity
    end
  end

  def discount?
    self.line_items.any?{|li| li.discount.to_f < 1}
  end

end


