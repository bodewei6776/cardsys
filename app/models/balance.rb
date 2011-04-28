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
  
 # default_scope where(:hide => false)

  
  belongs_to :who_balance,:class_name => "User",:foreign_key => "user_id"
  belongs_to :order
  belongs_to :member
  belongs_to :user
  attr_accessor :operation

  scope :balanced,where(:status => Const::YES)
  
  validate do |instance|
    if instance.use_card_to_balance_goods? && !order.should_use_card_to_balance_goods?
      errors[:base] << "卡不支持购买商品，只能订场"
    elsif instance.use_card_to_balance? && !order.member_card.has_enough_money_to_balance?(self)
      errors[:base] << "卡余额不足，不能结算"
    elsif instance.use_card_to_balance? && !order.member_card.is_avalible?
      errors[:base] << "卡已经过期，或者状态不正常不能结算"
    end
   
  end

  def member_card
    MemberCard.find(self.goods_member_card_id) #rescue nil
  end

  #before_create do |b| b.hide = false end
  
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
    #balance.catena_id   = order.catena_id
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

  def hide!
    self.hide = true
    self.save(false)
  end
  
  def merge_order(o)
    self.order_id      = o.id
    #self.catena_id     = o.catena_id
    self.member_type   = o.member_type
    self.member_id     = o.member_id
  end
  
  def process
    operation == 'change' ? change : balance 
  end
  
  def change
    save
  end

  def change_note_by(user)
    self.change_note = "订单消费总价变更（#{self.book_record_amount + self.goods_amount}  变为#{ self.book_record_realy_amount + self.goods_realy_amount}）,修改人#{user.login}"
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
    when Balance_Way_Use_Card then '记账'
    when Balance_Way_Use_Cash then '现金'
    when Balance_Way_Use_Post then 'POS机'
    when Balance_Way_Use_Bank then '银行'
    when Balance_Way_Use_Guazhang then '挂账'
    when Balance_Way_Use_Counter  then '计次'
    when Balance_Way_Use_Check then '支票'
    else '无'
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
      "￥#{goods_realy_amount + book_record_realy_amount}元"
    end
  end

   def balance_realy_amount_desc
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

  ####### for reports #########

  def self.balances_on_date_and_ways(date,ways)
    self.balanced.where(["date(created_at) = ? and (balance_way in (?) or goods_balance_type in (?))", date,ways,ways]).includes(:order)
  end

  def self.total_balance_on_date_any_ways(date,ways)
    data = self.balanced.where(["date(created_at) = ? and (balance_way in (?) or goods_balance_type in (?))", date,ways,ways])
    data.present? ? data.inject(0){|sum,b| 
      #sum +=((b.balance_way != 7 && ways.include?(b.balance_way.to_s)) ?  b.book_record_realy_amount : 0) 
      #sum +=(ways.include?(b.goods_balance_type.to_s) ? b.goods_realy_amount : 0) 

      sum += b.total_balance_each_balance(ways)
    } : 0
  end

  def self.total_balance_on_month_any_ways(date,ways)
    data = self.balanced.where(["date_format(created_at,'%Y-%m') = ? and (balance_way in (?) or goods_balance_type in (?))", date.strftime("%Y-%m"),ways,ways])
    data.present? ? data.inject(0){|sum,b| 
      #sum +=((b.balance_way != 7 && ways.include?(b.balance_way.to_s)) ?  b.book_record_realy_amount : 0) 
      #sum +=(ways.include?(b.goods_balance_type.to_s) ? b.goods_realy_amount : 0) 
      sum += b.total_balance_each_balance(ways)
    } : 0
  end

  def total_balance_each_balance(ways)
    total = 0
    if self.balance_way == 7
    elsif self.balance_way !=7 && ways.include?(self.balance_way.to_s)
      total += self.book_record_realy_amount
    end

    if ways.include?(self.goods_balance_type.to_s)
      total += self.goods_realy_amount
    end
    total

  end

  def self.total_count_on_date_any_ways(date,ways)
    data = self.balanced.where(["date(created_at) = ? and (balance_way in (?))", date,ways])
    data.present? ? data.inject(0){|sum,b|
      sum += ((b.balance_way == 7) ? b.count_amount : 0)
    } : 0
  end

  def self.total_count_on_month_any_ways(date,ways)
    data = self.balanced.where(["date_format(created_at,'%Y-%m') = ? and (balance_way =7 )", date.strftime("%Y-%m")])
    data.present? ? data.inject(0){|sum,b|
      sum +=  b.count_amount 
    } : 0
  end

  def coach_amount(pay_ways)
    if(pay_ways.include?self.goods_balance_type.to_s)
    self.order.coach_items.present? ?  self.order.coach_items.inject(0){|sum,c| sum + c.amount} : 0
    else
      0
    end
  end

  def good_amount_by_type(type,ways)
    return 0 unless ways.include?(self.goods_balance_type.to_s)
    product_items =  self.order.product_items(:include =>:good)
    product_items = (product_items.present? ? product_items.select{|g| g.good.good_type == type.id} : [])
    product_items.present? ? product_items.inject(0){|sum,c| sum + c.amount} : 0
  end

  def self.total_book_records_balance_on_date_any_ways(date,ways)
    #data = self.balanced.where(["date(created_at) = ? and (balance_way in (?) or goods_balance_type in (?))", date,ways,ways])
    data = self.balanced.where(["date(created_at) = ? and (balance_way in (?))", date,ways])
    data.present? ? data.inject(0){|sum,b| 
      sum += ((b.balance_way != 7) ? b.book_record_realy_amount : 0)
    } : 0
  end

  def self.total_book_records_balance_on_month_any_ways(date,ways)
    #data = self.balanced.where(["date_format(created_at,'%Y-%m') = ? and (balance_way in (?) or goods_balance_type in (?))", date.strftime("%Y-%m"),ways,ways])
    data = self.balanced.where(["date_format(created_at,'%Y-%m') = ? and (balance_way in (?))", date.strftime("%Y-%m"),ways])
    data.present? ? data.inject(0){|sum,b| 
      sum += ((b.balance_way != 7 ) ? b.book_record_realy_amount : 0)
    } : 0
  end


  def self.total_coach_balance_on_date_any_ways(date,ways)
    data = self.balanced.where(["date(created_at) = ? and (goods_balance_type in (?))", date,ways])
    data.present? ? data.inject(0){|sum,b| sum += b.coach_amount(ways) } : 0
  end


  def self.total_coach_balance_on_month_any_ways(date,ways)
    data = self.balanced.where(["date_format(created_at,'%Y-%m') = ? and (goods_balance_type in (?))", date.strftime("%Y-%m"),ways])
    data.present? ? data.inject(0){|sum,b| sum += b.coach_amount(ways) } : 0
  end


  def self.total_goods_balance_on_date_any_ways(date,ways,gt)
    data = self.balanced.where(["date(created_at) = ? and (goods_balance_type in (?))", date,ways])
    data.present? ? data.inject(0){|sum,b| sum + b.good_amount_by_type(gt,ways)} : 0
  end

  def self.total_goods_balance_on_month_any_ways(date,ways,gt)
    data = self.balanced.where(["date_format(created_at,'%Y-%m') = ? and (goods_balance_type in (?))", date.strftime("%Y-%m"),ways])
    data.present? ? data.inject(0){|sum,b| sum + b.good_amount_by_type(gt,ways)} : 0
  end

  def book_record_span
    self.order.book_record.start_hour.to_s + ":00 - " + self.order.book_record.end_hour.to_s + ":00"
  end

  def self.good_stat_per_date_by_type(date,type)
    balances = self.balanced.where(["date(created_at) = ?", date])
    product_items = balances.present? ? balances.collect{|b| b.order.product_items } : []
    product_items = product_items.flatten.uniq
    hash = {}
    product_items.each do |pi| 
      next if pi.good.good_type != type.id
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

  def balance_amount_by_ways(ways)
    money,count = 0,0
    (money += self.goods_realy_amount) if ways.include?(self.goods_balance_type.to_s)
    #  if self.balance_way == 7 #&& ways.include?("7")
    #    count += self.count_amount
    #  else
    #    money += self.book_record_realy_amount
    #  end
    if ways.include?("7") && self.balance_way == 7
      count += self.count_amount
    else
      if ways.include?(self.balance_way.to_s)
        money += self.book_record_realy_amount
      end
    end
    if count > 0
      return "#{money}元 #{count}次"
    else
      return money
    end

  end

end
