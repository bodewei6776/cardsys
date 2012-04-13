# -*- encoding : utf-8 -*-
class Balance < ActiveRecord::Base
  has_many :logs, :as => :item

  BALANCE_WAYS = {
    "card" => "记账",
    "counter" => "计次",
    "cash" => "现金",
    "pos" => "POS机",
    "bank" => "转账",
    "guazhang" => "挂账",
    "check" => "支票"
  }

  belongs_to :who_balance, :class_name => "User", :foreign_key => "user_id"
  belongs_to :order
  belongs_to :member
  belongs_to :user
  has_many :order_items

  scope :with_balance_way, lambda { |balance_way| { :conditions => { :balance_way => balance_way } } }
  scope :balanced,         lambda { { :conditions => ["orders.state = ?", "balanced"], :joins => :order } }
  scope :unbalanced,       lambda { { :conditions => ["orders.state != ?", "balanced"], :joins => :order } }

  accepts_nested_attributes_for :order_items
  validates_presence_of :price, :message => "价格不能空"
  validates_presence_of :final_price, :message => "折后价格不能空"

  validate do |instance|
    if instance.balance_way == "counter" && !order.members_card.has_enough_count_to_balance?(self)
      errors[:base] << "卡余次不足，不能结算"
    elsif instance.balance_way == "card" && order.
      errors[:base] << "卡不支持购买商品，只能订场"
    elsif instance.balance_way == "card" && !order.members_card.has_enough_money_to_balance?(self)
      errors[:base] << "卡余额不足，不能结算"
    elsif instance.balance_way == "card" && !order.members_card.is_avalible?
      errors[:base] << "卡已经过期，或者状态不正常不能结算"
    end
  end

  after_create :deduct_money_from_card_and_mark_order_as_paid

  delegate :members_card, :to => :order

  def deduct_money_from_card_and_mark_order_as_paid
    return true  unless self.order.is_member?
    if self.balance_way == "counter"
      self.members_card.left_times -= self.price
    elsif self.balance_way == "card" && self.order.members_card
      self.members_card.left_fee -= self.final_price
    end

    self.members_card.save(:validate => false)

    if self.order.reload.order_items.all?(&:balanced?)
      # skip callbacks 
      self.order.update_column(:state, "balanced")
    end

    true
  end

  def order_items_attributes=(attrs)
    attrs.each do |key, element|
      next if  element["checked"].nil? or element["checked"] == "0"
      oi = OrderItem.find(element["id"])
      oi.discount = element["discount"]
      oi.price_after_discount = element["price_after_discount"]
      if CourtBookRecord === oi.item && self.balance_way == "counter"
        oi.price_after_discount = self.order.hours
      end
      oi.balanced = true
      self.order_items << oi
    end
  end


  def money_spent_on
    if self.balance_way == "counter"
      "#{self.order.court_book_record.court.name} #{self.book_record_span}"
    else
      self.order_items.collect do |oi|
        case oi.item
        when CourtBookRecord
          "#{self.order.court_book_record.court.name} #{self.book_record_span}"
        when CoachBookRecord
          "#{oi.item.name} #{self.book_record_span}"
        when Good
          "#{oi.item.name}"
        end
      end.join("/")
    end
  end


  def balance_way_desc
    balance_way_desciption(balance_way)
  end

  def card
    members_card.card
  end

  def balance_way_desciption(way = nil)
    BALANCE_WAYS[way||self.balance_way] || "无"
  end

  def balance_real_amount_desc
    if balance_way == "counter"
      "#{final_price}次"
    else
      "￥#{final_price}元"
    end
  end

  def balance_amount_by_ways(ways)
    if self.balance_way == "counter"
      "#{self.final_price}次"
    else
      "#{self.final_price}元"
    end
  end


  ####### for reports #########

  def self.balances_on_date_and_ways(date, ways)
    where(["date(created_at) = ? and (balance_way in (?))", date, ways])
  end

  def self.balances_on_month_and_ways(date,ways)
    where(["date_format(created_at,'%Y-%m') = ? and balance_way in (?)", date.strftime("%Y-%m"),ways])
  end


  def self.total_balance_on_date_any_ways(date, ways)
    data = balances_on_date_and_ways(date, ways)
    if ways.include?("counter")
      money = data.select{|balance| balance.balance_way != "counter" }.sum(&:final_price)
      count = data.select{|balance| balance.balance_way == "counter"}.sum(&:final_price)
      "#{money}元/#{count}次"
    else
      money = data.select{|balance| balance.balance_way != "counter" }.sum(&:final_price)
      "#{money}元" 
    end
  end

  def self.total_balance_on_month_any_ways(date, ways)
    data =  balances_on_month_and_ways(date, ways)
    if ways.include?("counter")
      money = data.select{|balance| balance.balance_way != "counter" }.sum(&:final_price)
      count = data.select{|balance| balance.balance_way == "counter"}.sum(&:final_price)
      "#{money}元/#{count}次"
    else
      money = data.select{|balance| balance.balance_way != "counter" }.sum(&:final_price)
      "#{money}元" 
    end
  end

  def self.total_count_on_date_any_ways(date, ways)
    data = where(["date(created_at) = ? and (balance_way in (?))", date, ways])
    data.present? ? data.inject(0){|sum,b|
      sum += ((b.balance_way == "counter") ? b.final_price : 0)
    } : 0
  end

  def self.total_count_on_month_any_ways(date,ways)
    data = where(["date_format(created_at,'%Y-%m') = ? and (balance_way = 'counter' )", date.strftime("%Y-%m")])
    data.present? ? data.inject(0){|sum,b|
      sum +=  b.count_amount 
    } : 0
  end

  def coach_amount(pay_ways)
    return 0 unless pay_ways.include?(self.balance_way)
    return self.order_items.select{|oi| oi.item.is_a? CoachBookRecord }.sum(&:price_after_discount)
  end


  def book_record_amount(pay_ways)
    return 0 unless pay_ways.include?(self.balance_way)
    return self.order_items.select{|oi| oi.item.is_a? CourtBookRecord }.sum(&:price_after_discount)
  end

  def goods_amount(type, ways)
    return 0 unless ways.include?(self.balance_way)
    return self.order_items.select{|oi| (oi.item.is_a? Good) && oi.item.category == type}.sum(&:price_after_discount)
  end

  def good_amount_by_type(type, ways)
    #return 0 unless ways.include?(self.balance_way)
    return self.order_items.select{|oi| (oi.item.is_a? Good) && oi.item.category.parent == type }.sum(&:price_after_discount)
  end

  def self.total_book_records_balance_on_date_any_ways(date, ways)
    data = balances_on_date_and_ways(date, ways)
    sum = 0
    count = 0
    data.each do |element|
      sum += element.book_record_amount(ways) if element.balance_way != "counter" && ways.include?(element.balance_way)
      count += element.book_record_amount(ways) if element.balance_way == "counter" && ways.include?("counter")
    end

    "#{sum}元/#{count}次"
  end

  def self.total_book_records_balance_on_month_any_ways(date, ways)
    data = balances_on_month_and_ways(date, ways)
    sum = 0
    count = 0
    data.each do |element|
      sum += element.book_record_amount(ways) if element.balance_way != "counter" && ways.include?(element.balance_way)
      count += element.book_record_amount(ways) if element.balance_way == "counter" && ways.include?("counter")
    end

    "#{sum}元/#{count}次"
  end


  def self.total_coach_balance_on_date_any_ways(date,ways)
    data = balances_on_date_and_ways(date, ways)
    data.present? ? data.inject(0){|sum,b| sum += b.coach_amount(ways) } : 0
  end


  def self.total_coach_balance_on_month_any_ways(date,ways)
    data = balances_on_month_and_ways(date,ways)
    data.present? ? data.inject(0){|sum,b| sum += b.coach_amount(ways) } : 0
  end


  def self.total_goods_balance_on_date_any_ways(date,ways,gt)
    data = balances_on_date_and_ways(date, ways)
    data.present? ? data.inject(0){|sum,b| sum += b.good_amount_by_type(gt, ways) } : 0
  end

  def self.total_goods_balance_on_month_any_ways(date, ways, gt)
    data = balances_on_month_and_ways(date, ways)
    data.present? ? data.inject(0){|sum, b| sum += b.goods_amount(gt, ways) } : 0
  end

  def book_record_span
    self.order.court_book_record.start_hour.to_s + ":00 - " + self.order.court_book_record.end_hour.to_s + ":00"
  end

  def self.good_stat_per_date_by_type(date,type)
    balances = where(["date(created_at) = ?", date])
    product_items = balances.present? ? balances.collect{|b| b.order.product_items } : []
    product_items = product_items.flatten.uniq
    hash = {}
    product_items.each do |pi| 
      next if pi.good.category.parent_id != type.id
      if hash[pi.good]
        hash[pi.good] = hash[pi.good] + pi.quantity 
      else
        hash[pi.good] = pi.quantity
      end
    end
    hash
  end

  def self.good_total_per_date_by_type(date,type)
    stat = self.good_stat_per_date_by_type(date,type)
    if stat.present?
      stat.inject(0){|sum,record| sum + record[0].price * record[1]} 
    else
      0
    end
  end

end
