require 'order_ext/member_order'
class OrderItem < ActiveRecord::Base

  TYEP_STRING_MAP = {
    "CourtBookRecord"  => "场地预定",
    "CoachBookRecord"  => "教练预约", 
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
  belongs_to :order
  belongs_to :balance

  before_save :update_good_inventory, :only => :update  
  before_destroy :update_good_inventory_before_destroy
  after_create :set_default_discount_and_discount_price

  validates_numericality_of :quantity, :only_integer => true, :greater_than => 0
  validates_numericality_of :discount, :greater_than => 0, :less_or_equal_than => 10, :allow_blank => true
  validates_numericality_of :price_after_discount, :greater_or_equal_than => 0, :allow_blank => true

  attr_accessor :checked


  def self.new_by_good(good, order_id)
    self.find_by_item_type_and_item_id_and_order_id("Good", good.id, order_id) || new(:quantity => 0, :item => good, :order_id => order_id)
  end

  def type_name
    TYEP_STRING_MAP[item.class.name]    
  end

  def quantity_or_time
    quantity
  end

  def total_cost
     "#{self.total_money_price}元" + (self.total_count ? "/#{self.total_count}次" : "") 
  end


  # 恢复前面库存的数量
  def update_good_inventory
    return true unless item.is_a?(Good)
    product = item
    product.count_front_stock_in += ( self.quantity - (self.quantity_was || 0) ) 
    product.count_front_stock -= (self.quantity - (self.quantity_was || 0))
    product.count_total_now = product.count_front_stock + product.count_back_stock
    product.save
  end

  def update_good_inventory_before_destroy
    if item.is_a?(Good)
      item.count_front_stock += (self.quantity) 
      item.count_total_now += (self.quantity)
      item.save
    end
  end

  def set_price_for_good
    return unless self.item
    return unless self.item.is_a? Good
    self.unit_money_price = self.item.price
    self.total_money_price = self.item.price * self.quantity
    self.discount = 10
    self.price_after_discount = self.total_money_price
    save
  end

  def set_default_discount_and_discount_price
    self.discount = 10
    self.price_after_discount = self.total_money_price
    save
  end


  def self.coache_items_in_time_span(order)
    return [] if order.coaches.blank? || order.book_record.blank?
    exist_coaches = coaches.where("item_id in (#{order.coaches.map(&:id).join(',')})")
    exist_coaches = exist_coaches.where("order_id <> #{order.id}") unless order.new_record?
    exist_coaches.where(:order_date => order.record_date).where(["start_hour < :end_time AND end_hour > :start_time",
                                                                {:start_time => order.start_hour,:end_time => order.end_hour}]).all
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



  def name
    item.try(:name) || ""
  end
end
