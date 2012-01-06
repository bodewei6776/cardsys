class Balance < ActiveRecord::Base

  BALANCE_WAYS = {
    "card" => "记账",
    "cash" => "现金",
    "post" => "POS机",
    "bank" => "银行",
    "guazhang" => "挂账",
    "counter" => "计次",
    "check" => "支票"
  }

  belongs_to :who_balance,:class_name => "User",:foreign_key => "user_id"
  belongs_to :order
  belongs_to :member
  belongs_to :user
  has_many :order_items

  accepts_nested_attributes_for :order_items
  validates_presence_of :price, :message => "价格不能空"
  validates_presence_of :final_price, :message => "折后价格不能空"

  after_create :deduct_money_from_card_and_mark_order_as_paid

  delegate :members_card, :to => :order

  def deduct_money_from_card_and_mark_order_as_paid
    if self.balance_way == "counter" && self.order.members_card.try(:is_counter_card?)
      self.members_card.left_times -= self.price
    elsif self.balance_way == "card" && self.order.members_card
      self.members_card.left_fee -= self.final_price
    end

    self.members_card.save

    if self.order.order_items.all?(&:balanced?)
      self.order.balance!
    end

    true
  end


  def order_items_attributes=(attrs)
    attrs.each do |key, element|
      next if element["checked"] == "0"
      oi = OrderItem.find(element["id"])
      oi.discount = element["discount"]
      oi.price_after_discount = element["price_after_discount"]
      oi.balanced = true
      self.order_items << oi
    end  
  end

  validate do |instance|
    return true unless order.is_member?
    if instance.balance_way == "card" && !order.should_use_card_to_balance_goods?
      errors[:base] << "卡不支持购买商品，只能订场"
    elsif instance.balance_way == "card" && !order.members_card.has_enough_money_to_balance?(self)
      errors[:base] << "卡余额不足，不能结算"
    elsif instance.balance_way == "card" && !order.members_card.is_avalible?
      errors[:base] << "卡已经过期，或者状态不正常不能结算"
    end
  end

  def self.default_balance_way_by_order(order)
    if order.is_member?
      order.member_card.card.is_counter_card? ? Balance_Way_Use_Counter : Balance_Way_Use_Card
    else
      Balance_Way_Use_Cash
    end
  end

  def self.default_goods_balance_way_by_order(order)
    (order.should_use_card_to_balance_goods? ? Balance_Way_Use_Card : Balance_Way_Use_Cash)
  end


  #TODO
  def do_balance!
    return true if self.status == Const::YES

    # change status
    self.order.book_record.balance if self.order.book_record
    self.update_attribute(:status, Const::YES)

    return true  unless order.is_member?

    card = order.member_card.card
    member_card = order.member_card


    if use_card_counter_to_balance?
      member_card.left_times -= self.count_amount
    elsif use_card_to_balance?
      member_card.left_fee -= self.book_record_real_amount.to_i
    end

    if use_card_to_balance? and order.should_use_card_to_balance_goods?
      member_card.left_fee -= self.other_real_amount.to_i
    end

    member_card.save
  end

  def change_note_by(user)
    self.change_note = "订单消费总价变更（#{self.book_record_amount + self.goods_amount}  变为#{ self.book_record_real_amount + self.other_real_amount}）,修改人#{user.login}"
    save
  end


  def balance_way_desc
    balance_way_desciption(balance_way)
  end


  def card
    @card ||= (order.is_member? ? order.member_card.card : '')
    @card.blank? ? nil : @card
  end

  def should_use_counter_to_balance?
    card && (card.is_counter_card? || card.is_zige_card?)
  end

  def should_use_card_to_blance?
    card && !card.is_counter_card?
  end

  def balance_way_desciption(way = nil)
    BALANCE_WAYS[way||self.balance_way] || "无"
  end

  def ensure_use_card_counter?
    use_card_to_balance_book_record? && card && (card.is_counter_card? || (card.is_zige_card? && use_card_counter_to_balance?))
  end

  def amount_by_card
    card_amount = 0
    if use_card_to_balance? 
      if use_card_counter_to_balance?
        card_amount += count_amount
      else
        card_amount += book_record_real_amount.to_i if use_card_to_balance_book_record?
        card_amount += other_real_amount.to_i       if use_card_to_balance_goods?
      end
    end
    card_amount
  end

  def book_record_real_amount
    self.balance_items.select{ |bi| bi.order_item.item_type == "BookRecord" }.sum(&:real_price)
  end

  def other_real_amount
    self.balance_items.select{ |bi| bi.order_item.item_type != "BookRecord" }.sum(&:real_price)
  end

  def other_amount
    self.balance_items.select{ |bi| bi.order_item.item_type != "BookRecord" }.sum(&:price)
  end

  def book_record_amount_desc
    if ensure_use_card_counter?
      "#{count_amount}次"
    else
      "￥#{book_record_real_amount}元"
    end
  end

  def other_amount_desc
    "￥#{other_amount}元"
  end

  def other_amount_real_desc
    "￥#{other_amount}元"
  end

  def balance_amount_desc
    if ensure_use_card_counter?
      "￥#{other_amount}元;#{book_record_amount_desc}"
    else
      "￥#{other_amount + book_record_real_amount}元"
    end
  end

  def balance_realy_amount_desc
    if ensure_use_card_counter?
      "￥#{other_real_amount}元;#{book_record_amount_desc}"
    else
      "￥#{other_real_amount + book_record_real_amount}元"
    end
  end


  def balance_amount
    book_record_amount.to_i + other_amount.to_i
  end

  def balance_realy_amount
    book_record_real_amount.to_i + other_real_amount.to_i
  end

  def total_changed?
    self.amount != self.real_amount 
  end

  ####### for reports #########

  def self.balances_on_date_and_ways(date,select,ways)
    case select
    when "1" #记账
      where(["date(created_at) = ? and (balance_way=1 or balance_way=1)", date]).includes(:order)
    when "7"
      where(["date(created_at) = ? and balance_way=7", date]).includes(:order)
    else
      where(["date(created_at) = ? and (balance_way in (?) or balance_way in (?))", date,ways,ways]).includes(:order)
    end
  end

  def self.balances_on_month_and_ways(date,select,ways)
    case select
    when "1" #记账
      where(["date_format(created_at,'%Y-%m') = ? and (balance_way=1 or balance_way=1)", date.strftime("%Y-%m")]).includes(:order)
    when "7"
      where(["date_format(created_at,'%Y-%m') = ? and balance_way=7", date.strftime("%Y-%m")]).includes(:order)
    else
      where(["date_format(created_at,'%Y-%m') = ? and (balance_way in (?) or balance_way in (?))", date.strftime("%Y-%m"),ways,ways]).includes(:order)
    end
  end



  def self.total_balance_on_date_any_ways(date,select,ways)
    data = balances_on_date_and_ways(date,select,ways)
    case select
    when "1"
      sum = 0
      data.each do |b|
        sum += b.book_record_real_amount if b.balance_way == 1
        sum += b.other_real_amount if b.balance_way == 1
      end
      return sum.to_s + "元"
    when "7"
      count = 0
      data.each do |b|
        count += b.count_amount if b.balance_way == 7
      end
      return count.to_s + "次"
    else
      sum = 0
      data.each do |b|
        sum += b.book_record_real_amount if ways.include?(b.balance_way.to_s)
        sum += b.other_real_amount if ways.include?(b.balance_way.to_s)
      end
      return sum.to_s + "元"
    end
  end

  def self.total_balance_on_month_any_ways(date,select,ways)
    data =  balances_on_month_and_ways(date,select,ways)
    case select
    when "1"
      sum = 0
      data.each do |b|
        sum += b.book_record_real_amount if b.balance_way == 1
        sum += b.other_real_amount if b.balance_way == 1
      end
      return sum.to_s + "元"
    when "7"
      count = 0
      data.each do |b|
        count += b.count_amount if b.balance_way == 7
      end
      return count.to_s + "次"
    else
      sum = 0
      data.each do |b|
        sum += b.book_record_real_amount if ways.include?(b.balance_way.to_s)
        sum += b.other_real_amount if ways.include?(b.balance_way.to_s)
      end
      return sum.to_s + "元"

    end
  end

  def total_balance_each_balance(ways)
    total = 0
    if self.balance_way == 7
    elsif self.balance_way !=7 && ways.include?(self.balance_way.to_s)
      total += self.book_record_real_amount
    end

    if ways.include?(self.balance_way.to_s)
      total += self.other_real_amount
    end
    total

  end

  def self.total_count_on_date_any_ways(date,select,ways)
    data = where(["date(created_at) = ? and (balance_way in (?))", date,ways])
    data.present? ? data.inject(0){|sum,b|
      sum += ((b.balance_way == 7) ? b.count_amount : 0)
    } : 0
  end

  def self.total_count_on_month_any_ways(date,select,ways)
    data = where(["date_format(created_at,'%Y-%m') = ? and (balance_way =7 )", date.strftime("%Y-%m")])
    data.present? ? data.inject(0){|sum,b|
      sum +=  b.count_amount 
    } : 0
  end

  def coach_amount(select,pay_ways)
    case select
    when "1","7"
      ((select == self.balance_way.to_s) && self.order.coach_items.present?) ?\
      self.order.coach_items.inject(0){|sum,c| sum + c.amount} : 0
    else
      if(pay_ways.include?self.balance_way.to_s)
        self.order.coach_items.present? ?  self.order.coach_items.inject(0){|sum,c| sum + c.amount} : 0
      else
        0
      end
    end
  end

  def good_amount_by_type(type,select,ways)
    case select
    when "7" 
      return '0'
    when '1'
      return '0' if self.balance_way != 1
      product_items =  self.order.product_items(:include =>{:good =>{:include => :category}})
      product_items = (product_items.present? ? product_items.select{|g| g.item.category.parent_id == type.id} : [])
      product_items.present? ? product_items.inject(0){|sum,c| sum + c.amount} : 0

    else
      return '0' if ways.include?(self.balance_way)
      product_items =  self.order.product_items(:include =>{:good =>{:include => :category}})
      product_items = (product_items.present? ? product_items.select{|g| g.good.category.parent_id == type.id} : [])
      product_items.present? ? product_items.inject(0){|sum,c| sum + c.amount} : 0
    end
  end

  def self.total_book_records_balance_on_date_any_ways(date,select,ways)
    data = balances_on_date_and_ways(date,select,ways)
    case select
    when "7"
      count = 0
      data.each do |b|
        count += b.count_amount if b.balance_way == 7
      end
      return count.to_s + "次"
    when "1"
      sum = 0
      data.each do |b|
        sum += b.book_record_real_amount if b.balance_way == 1
      end
      return sum.to_s + "元"
    else
      sum = 0
      data.each do |b|
        sum += b.book_record_real_amount if ways.include?(b.balance_way.to_s)
      end
      return sum.to_s + "元"
    end
  end

  def self.total_book_records_balance_on_month_any_ways(date,select,ways)
    data = balances_on_month_and_ways(date,select,ways)
    case select
    when "7"
      count = 0
      data.each do |b|
        count += b.count_amount if b.balance_way == 7
      end
      return count.to_s + "次"
    when "1"
      sum = 0
      data.each do |b|
        sum += b.book_record_real_amount if b.balance_way == 1
      end
      return sum.to_s + "元"
    else
      sum = 0
      data.each do |b|
        sum += b.book_record_real_amount if ways.include?(b.balance_way.to_s)
      end
      return sum.to_s + "元"
    end

  end


  def self.total_coach_balance_on_date_any_ways(date,select,ways)
    case select
    when "1","7"
      data = where(["date(created_at) = ? and (balance_way=?)", date,select])
    else
      data = where(["date(created_at) = ? and (balance_way in(?))", date,ways])
    end
    data.present? ? data.inject(0){|sum,b| sum += b.coach_amount(select,ways) } : 0
  end


  def self.total_coach_balance_on_month_any_ways(date,select,ways)
    data = where(["date_format(created_at,'%Y-%m') = ? and (balance_way in (?))", date.strftime("%Y-%m"),ways])
    data.present? ? data.inject(0){|sum,b| sum += b.coach_amount(ways) } : 0
  end


  def self.total_goods_balance_on_date_any_ways(date,select,ways,gt)
    case select
    when "7"
      return "0"
    when "1"
      data = where(["date(created_at) = ? and (balance_way=1)", date])
      data.present? ? data.inject(0){|sum,b| sum + b.good_amount_by_type(gt,select,ways)} : 0
    else
      data = where(["date(created_at) = ? and (balance_way in (?))", date,ways])
      data.present? ? data.inject(0){|sum,b| sum + b.good_amount_by_type(gt,select,ways)} : 0
    end
  end

  def self.total_goods_balance_on_month_any_ways(date,select,ways,gt)
    case select
    when "7"
      return "0"
    when "1"
      data = where(["date_format(created_at,'%Y-%m') = ? and (balance_way=1)", date.strftime('%Y-%m')])
      data.present? ? data.inject(0){|sum,b| sum + b.good_amount_by_type(gt,select,ways)} : 0
    else
      data = where(["date_format(created_at,'%Y-%m') = ? and (balance_way in (?))", date.strftime("%Y-%m"),ways])
      data.present? ? data.inject(0){|sum,b| sum + b.good_amount_by_type(gt,select,ways)} : 0
    end
  end

  def book_record_span
    self.order.book_record.start_hour.to_s + ":00 - " + self.order.book_record.end_hour.to_s + ":00"
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

  def balance_amount_by_ways(select,ways)
    case select
    when "1"
      sum = 0
      sum += self.book_record_real_amount if self.balance_way == 1
      sum += self.other_real_amount if self.balance_way == 1
      return sum.to_s + "元"
    when "7"
      return self.count_amount.to_s + "次"  if self.balance_way == 7
    else
      sum = 0
      sum += self.other_real_amount if ways.include?(self.balance_way.to_s)
      sum += self.book_record_real_amount if ways.include?(self.balance_way.to_s)
      return sum.to_s + "元" 
    end
  end

  def balance_person_desc
    member = self.member
    member_card = self.member_card

    result = if member_card.member == member
               "本人"
             elsif member_card.granters.include? member
               "授权人(#{member.name})"
             else
               "未知"
             end
    return result
  end

  def update_amount
    reload
    self.count_amount = self.amount = self.real_amount = 0
    self.balance_items.each do |item|
      self.count_amount += item.count_amount
      self.amount       += item.price
      self.real_amount  += item.real_price
    end
    save
  end


  def name
    self.order_item.name
  end

end
