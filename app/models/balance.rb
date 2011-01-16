class Balance < ActiveRecord::Base
  
  Order_Type_Book_Record = 1
  Order_Type_Good        = 2
  
  Balance_Way_Use_Card  = 1
  Balance_Way_Use_Cash  = 2
  Balance_Way_Use_Post  = 3
  Balance_Way_Use_Bank  = 4
  Balance_Way_Use_Check = 5
  Balance_Way_Use_Guazhang = 6
  Balance_Way_Use_Counter  = 7

  
  belongs_to :order
  attr_accessor :operation
  
  validate do |instance|
    if instance.use_card_to_balance_goods? && !order.should_use_card_to_balance_goods?
      errors[:base] << "卡不支持购买商品，只能订场"
    elsif instance.use_card_to_balance? && !order.member_card.has_enough_money_to_balance?(self)
      errors[:base] << "卡余额不足，不能结算"
    elsif instance.use_card_to_balance? && !order.member_card.is_avalible?
      errors[:base] << "卡已经过期，或者状态不正常不能结算"
    end
  end
  
  def self.new_from_order(order)
    balance = new
    balance.order_id      = order.id
    balance.goods_amount  = order.product_amount
    balance.goods_realy_amount  = order.product_amount
    if order.is_member? && order.member_card.card.is_counter_card?
      balance.count_amount  = order.book_record_amount
    else
      balance.book_record_amount = order.book_record_amount
      balance.book_record_realy_amount  = order.book_record_amount
    end
    balance.balance_way = default_balance_way_by_order(order)
    balance.goods_balance_type = default_goods_balance_way_by_order(order)
    balance.catena_id   = order.catena_id
    balance.member_type = order.member_type
    balance
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
  
  def merge_order(o)
    self.order_id      = o.id
    self.catena_id     = o.catena_id
    self.member_type   = o.member_type
  end
  
  def process
    operation == 'change' ? change : balance 
  end
  
  def change
    save
  end
  
  def balance
    self.status = Const::YES
    save && order.balance
  end
  
  def to_change?
    operation == 'change'
  end
  
  def to_balance?
    operation.blank? || operation == 'balance'
  end
  
  def balance_way_desc
    balance_way_desciption(balance_way)
  end
  
  def goods_balance_type_desc
    balance_way_desciption(goods_balance_type)
  end
  
  def use_card_to_balance_book_record?
    balance_way == Balance_Way_Use_Card || balance_way == Balance_Way_Use_Counter
  end
  
  def use_card_to_balance_goods?
     goods_balance_type == Balance_Way_Use_Card
  end
  
  def use_card_to_balance?
    use_card_to_balance_book_record? || use_card_to_balance_goods?
  end

  def use_card_counter_to_balance?
    balance_way == Balance_Way_Use_Counter
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
  
  def balance_way_desciption(way)
    case way
    when Balance_Way_Use_Card then '用卡'
    when Balance_Way_Use_Cash then '现金'
    when Balance_Way_Use_Post then 'Post机'
    when Balance_Way_Use_Bank then '银行'
    when Balance_Way_Use_Guazhang then '挂账'
    when Balance_Way_Use_Counter  then '计次'
    else ''
    end
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
        card_amount += book_record_realy_amount.to_i if use_card_to_balance_book_record?
        card_amount += goods_realy_amount.to_i       if use_card_to_balance_goods?
      end
    end
    card_amount
  end
  
  def book_record_amount_desc
    if ensure_use_card_counter?
      "#{count_amount}次"
    else
      "￥#{book_record_realy_amount}元"
    end
  end
  
  def goods_amount_desc
    "￥#{goods_realy_amount}元"
  end
  
  def balance_amount_desc
    if ensure_use_card_counter?
      "￥#{goods_realy_amount}元;#{book_record_amount_desc}"
    else
      "￥#{goods_realy_amount+book_record_realy_amount}元"
    end
  end
  
  def balance_amount
    book_record_amount.to_i + goods_amount.to_i
  end
  
  def balance_realy_amount
    book_record_realy_amount.to_i + goods_realy_amount.to_i
  end
  
end
