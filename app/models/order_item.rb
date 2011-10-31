require 'order_ext/member_order'
class OrderItem < ActiveRecord::Base

  TYEP_STRING_MAP = {
    "BookRecord"  => "场地预定",
    "Coach"       => "教练预定", 
    "Good"        => "购买商品"
  }

  Item_Type_Book_Record = "BookRecord"
  Item_Type_Coache = "Coach"
  Item_Type_Product = "Good"

  scope :coaches,where(:item_type => Item_Type_Coache)
  scope :book_records,where(:item_type => Item_Type_Book_Record)
  scope :good_records,where(:item_type => Item_Type_Product)
  scope :except_book_records,where("item_type <> #{Item_Type_Book_Record}")
  
  belongs_to :item, :polymorphic => true
  belongs_to    :order
  has_one :balance_item, :dependent => :destroy

  before_save :update_good_inventory, :only => :update  
  before_destroy :update_good_inventory_before_destroy
  after_save :update_balance_item
  



  # 恢复前面库存的数量
  def update_good_inventory
    return true unless item.is_a?(Good)
    product = item
    product.count_front_stock_in += ( self.quantity - self.quantity_was ) 
    product.count_front_stock -= (self.quantity - self.quantity_was) 
    product.count_total_now = product.count_front_stock + product.count_back_stock
    product.save
  end

  def update_good_inventory_before_destroy
    product = self.item
    if is_product? && product.is_a?(Good)
      product.count_front_stock += (self.quantity) 
      product.count_total_now += (self.quantity)
      product.save
    end

  end


  def self.coache_items_in_time_span(order)
    return [] if order.coaches.blank? || order.book_record.blank?
    exist_coaches = coaches.where("item_id in (#{order.coaches.map(&:id).join(',')})")
    exist_coaches = exist_coaches.where("order_id <> #{order.id}") unless order.new_record?
    exist_coaches.where(:order_date => order.record_date).where(["start_hour < :end_time AND end_hour > :start_time",
                                                                {:start_time => order.start_hour,:end_time => order.end_hour}]).all
  end

  def self.order_coaches(order)
    return true unless order.updating
    pending_coaches = coaches.where(:order_id => order.id) || []
    (order.coaches||[]).each_with_index do |coach,index|
      origin_coach_order_item = pending_coaches.find do |c| c.item_id == coach.id end
      book_record = order.book_record
      coach_item =  new
      coach_item.item_id    = coach.id
      coach_item.item_type  = Item_Type_Coache
      coach_item.quantity   = (origin_coach_order_item.present? ?  origin_coach_order_item.quantity  : book_record.hours)
      coach_item.price      = coach.fee
      coach_item.order_id   = order.id
      coach_item.start_hour = book_record.start_hour
      coach_item.end_hour   = book_record.end_hour
      coach_item.order_date = book_record.record_date#Date.today
      coach_item.save
    end
    pending_coaches.collect(&:destroy)
  end

  def self.order_book_record(order)
    return unless order.book_record
    book_record = order.book_record
    book_record_item = new
    book_record_item.item_id   = book_record.id
    book_record_item.item_type = Item_Type_Book_Record
    book_record_item.quantity  = book_record.hours
    book_record_item.price     = book_record.amount
    book_record_item.order_id  = order.id
    book_record_item.start_hour = book_record.start_hour
    book_record_item.end_hour   = book_record.end_hour
    book_record_item.order_date = book_record.record_date#Date.today
    book_record_item.save
  end

  def self.order_good(order, good)
    book_record  = order.book_record
    orignial_good = where(:order_id => order.id,:item_type => Item_Type_Product,:item_id => good.id).first
    good_item = orignial_good || new
    if good_item.new_record?
      good_item.item = good
      good_item.quantity    = good.order_count
      good_item.price       = good.price
      good_item.order_id    = order.id
    else
      good_item.quantity    = good_item.quantity + good.order_count
    end
    if good_item.save
      good.add_to_cart
      good_item
    else
      nil
    end
  end

  def do_agent
    self.start_hour = order.start_hour
    self.end_hour   = order.end_hour
    self.quantity   = order.hours
    save
  end


  def amount
    item_type == "BookRecord" ? item.amount : price * quantity
  end

  def do_balance
    save
  end

  def status_str
    self.order.balance.status == Const::YES ? '已结算' : '预定中'
  end

  def court_name
    court_id = BookRecord.find_by_id(self.item_id).try(:court_id)
    Court.find_by_id(court_id).try(:name)
  end

  def member_name
    begin Member.find(self.order.member_id).name rescue "" end
  end

  def coach_name
    begin Coach.find(self.item_id).name rescue "" end
  end

  def order_item_type_str
    TYEP_STRING_MAP[item_type]
  end


  def is_book_record?
    item_type == "BookRecord"
  end

  def is_coach?
    item_type == "Coach"
  end

  def is_product?
    item_type == "Good"
  end


  def update_balance_item
    balance_item = self.balance_item || BalanceItem.new(:balance_id => self.order.balance.id, 
                                                        :order_id => self.order_id, 
                                                        :order_item_id => self.id,
                                                        :discount_rate => 1,
                                                        :count_amount => 0)
    if item_type == "BookRecord"
      real_price = self.order.book_record.amount
      price = self.order.is_counter_card? ? self.order.book_record.amount_by_court : self.order.book_record.amount
      count_amount = self.order.book_record.hours
      balance_item.update_attributes(:price => price, :real_price => real_price, :count_amount => count_amount)
    else
      ap self.quantity
      ap self.price
      cal_price = self.quantity * self.price 
      balance_item.update_attributes(:price => cal_price,
                                     :real_price => cal_price)
    end
  end

  def name
    item.try(:name) || ""
  end
end
