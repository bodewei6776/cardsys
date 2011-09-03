require 'order_ext/member_order'
class OrderItem < ActiveRecord::Base


  Item_Type_Book_Record = 0
  Item_Type_Coache = 1
  Item_Type_Product = 2

  scope :book_record,lambda {|book_record_id| where(:item_type => Item_Type_Book_Record,:item_id => book_record_id) }
  scope :coaches,where(:item_type => Item_Type_Coache)
  scope :book_records,where(:item_type => Item_Type_Book_Record)
  scope :good_records,where(:item_type => Item_Type_Product)
  scope :except_book_records,where("item_type <> #{Item_Type_Book_Record}")
  
  belongs_to    :order
  before_create :set_initialize_attributes
  before_save :update_good_inventory,:only => [:update] 

  belongs_to :good,:foreign_key => "item_id"#,:conditions =>{:item_type => Item_Type_Product}

  before_destroy :update_good_inventory_before_destroy


  has_one :balance_item, :dependent => :destroy
  after_save :update_balance_item
  



  # 恢复前面库存的数量
  def update_good_inventory
    product = self.product
    if is_product? && product.is_a?(Good)
      product.count_front_stock_in += ( self.quantity - self.quantity_was ) 
      product.count_front_stock -= (self.quantity - self.quantity_was) 
      product.count_total_now = product.count_front_stock + product.count_back_stock
      product.save
    end
  end

  def update_good_inventory_before_destroy
    product = self.product
    if is_product? && product.is_a?(Good)
      product.count_front_stock += (self.quantity) 
      product.count_total_now += (self.quantity)
      product.save
    end

  end

  def set_initialize_attributes
    self.order_time = DateTime.now
  end

  def related_entry
    klass = related_entry_klass and klass.find_by_id(item_id)
  end

  def is_book_record?
    item_type == Item_Type_Book_Record
  end

  def is_coache?
    item_type == Item_Type_Coache
  end

  def is_product?
    item_type == Item_Type_Product
  end

  def related_entry_klass
    {Coach => is_coache?,BookRecord => is_book_record?,
      Good => is_product?}.find{|k,v|v}.first
  end

  def self.coache_items_in_time_span(order)
    return [] if order.coaches.blank?
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
      coach_item.order_time = DateTime.now
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
    book_record_item.quantity  = 1
    book_record_item.price     = book_record.amount_by_court
    book_record_item.order_id  = order.id
    book_record_item.start_hour = book_record.start_hour
    book_record_item.end_hour  =  book_record.end_hour
    book_record_item.order_time = DateTime.now
    book_record_item.order_date = Date.today
    book_record_item.save
  end

  def self.order_goolds(order,good)
    book_record  = order.book_record
    orignial_good = where(:order_id => order.id,:item_type => Item_Type_Product,:item_id => good.id).first
    good_item = orignial_good || new
    if good_item.new_record?
      good_item.item_id     = good.id
      good_item.item_type   = Item_Type_Product
      good_item.quantity    = good.order_count
      good_item.price       = good.price
      good_item.order_id    = order.id
      good_item.start_hour  = book_record.start_hour if book_record
      good_item.end_hour    = book_record.end_hour if book_record
      good_item.order_time  = DateTime.now
      good_item.order_date  = Date.today
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

  def product 
    case item_type
    when Item_Type_Product then Good.find_by_id(item_id)
    when Item_Type_Book_Record then BookRecord.find_by_id(item_id)
    else
      Coach.find_by_id(item_id)
    end
  end

  def amount
    is_book_record? ? product.amount(self) :  price*(quantity.to_f)
  end

  def do_balance
    self.paid_status = Const::YES
    save
  end

  def status_str
    paid_status == Const::YES ? '已结算' : '预定中'
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
    case
    when is_book_record? then "场地预定"
    when is_coache? then "教练预定"
    when is_product? then "购买商品"
    else ""
    end
  end


  def update_balance_item
    balance_item = self.balance_item || BalanceItem.new(:balance_id => self.order.balance.id, 
                                                        :order_id => self.order_id, 
                                                       :order_item_id => self.id,
                                                       :discount_rate => 1,
                                                       :count_amount => 0)
    balance_item.update_attributes(:price => self.quantity * self.price, 
                                   :real_price => self.quantity * self.price)
    balance_item.update_attributes(:count_amount => self.order.book_record.hours) if is_book_record?
  end

  def name
    case self.item_type
    when  Item_Type_Book_Record 
      self.court_name
    when Item_Type_Coache 
      self.coach_name
    when Item_Type_Product
      self.product.name
    else
      "no"
    end
  end
end
