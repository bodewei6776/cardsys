class Order < ActiveRecord::Base
  has_many    :balance_items
  belongs_to  :user
  belongs_to  :members_card
  belongs_to  :advanced_order
  has_many    :balances, :dependent => :destroy
  has_one     :court_book_record, :dependent => :destroy
  has_many    :coach_book_records, :dependent => :destroy
  has_many    :order_items
  belongs_to  :member
  has_one     :non_member
  belongs_to  :advanced_order

  validates  :members_card_id, :presence => {:message => "请选择会员卡"}, :if => proc { |order| order.is_member? }
  validates  :member_id, :presence => {:message => "请选择会员"}, :if => proc { |order| order.is_member? }
  validate :coach_valid

  accepts_nested_attributes_for :court_book_record
  accepts_nested_attributes_for :coach_book_records
  accepts_nested_attributes_for :non_member, :reject_if => proc {|non_member| non_member[:is_member] == "1" }
  attr_accessor :coach_ids
  after_save :save_order_items_for_court_and_coaches

  delegate :record_date,:end_hour,:start_hour,:hours, :to => :court_book_record

  def save_order_items_for_court_and_coaches
    court_book_record_order_item = self.order_items.find_or_initialize_by_item_type_and_item_id("CourtBookRecord", court_book_record.id)
    court_book_record_order_item.update_attributes(:quantity => court_book_record.hours,
                                                   :total_count => court_book_record.hours,
                                                   :total_money_price => court_book_record.price,
                                                   :discount => 10,
                                                   :price_after_discount => court_book_record.price)

    self.coach_book_records.each do |cbr|
      coach_order_item = self.order_items.find_or_initialize_by_item_type_and_item_id("CoachBookRecord", cbr.id) 
      coach_order_item.update_attributes(:quantity => court_book_record.hours,
                                        :unit_money_price => cbr.resource.fee,
                                        :total_money_price => cbr.resource.fee * court_book_record.hours,
                                        :discount => 10,
                                        :price_after_discount => cbr.resource.fee * court_book_record.hours)
    end

    self.order_items.each do |oi|
      oi.destroy if oi.item.nil?
    end

    true
  end

  def replace_by(order_attributes)
    new_order = Order.new(order_attributes)
  end

  def coach_valid
    return true if coach_ids.blank?
    coach_book_records.each do |c|
      errors.add(:base, c.conflict_book_record.to_s + "已经被预约") if c.conflict?
    end
  end

  def coach_order_items
    self.order_items.where(:item_type => "CoachBookRecord")
  end


  state_machine  :initial => :booked do

    after_transition :on => :cancel , :do => :destroy

    event :activate do
      transition :booked => :activated
    end

    event :want_sell do
      transition :booked => :to_be_sold
    end


    event :cancel_want_sell do
      transition :to_be_sold => :booked
    end

    event :sell do
      transition :to_be_sold => :sold_out
    end

    event :cancel do
      transition [:to_be_sold, :booked] => :canceld
    end

    event :balance do
      transition :activated => :balanced
    end
  end


  def coaches
    coach_book_records.collect(&:resource)
  end

  def coach_ids
    coach_book_records.collect(&:resource_id).join(",")
  end

  def coach_ids=(ids)
    @coaches = Coach.find(ids.split(",").uniq)
    self.coach_book_records = @coaches.collect do |c|
      cbr = CoachBookRecord.find_or_initialize_by_resource_type_and_resource_id("Coach", c.id)
      cbr.start_hour = start_hour 
      cbr.end_hour = end_hour
      cbr.alloc_date = order_date
      cbr
    end
  end

  def can_cancel?
    booked? && Setting.can_cancel_time_before_activate.from_now < court_book_record.start_time
  end

  def can_want_sell?
    booked?
  end

  def can_cancel_want_sell?
    to_be_sold?
  end

  def can_cancel_all?
    activated? && is_advanced_order?
  end


  def can_update_all?
    booked? && is_advanced_order?
  end

  def book_time_due?
    false
  end

  def to_be_sold_time_due?
    false
  end

  def can_activate?
    booked?
  end

  def can_order_goods?
    activated?
  end

  def can_print_order_balance?
    balanced?
  end

  def possible_balance_ways
    if self.is_member?
      if members_card.is_counter_card?
        possible_ways = ["counter"]
      else
        possible_ways = ["card"]
      end
    else
      possible_ways = []
    end
    possible_ways = possible_ways | ["cash", "post", "bank", "guazhang", "check"]
    Balance::BALANCE_WAYS.slice(*possible_ways).collect{|k, v| [v,k]}
  end


  def validates_assocations
    if is_member? && (member.nil? || member_card.nil?)
      errors[:base] << I18n.t('order_msg.order.member')
    elsif !is_member? && non_member.nil?
      errors[:base] << I18n.t('order_msg.order.non_member')
    else
      associations = order_associations.compact
      associations.each {|assocation|
        if assocation
          assocation.is_ready_to_order?(self)
          assocation.valid? if assocation.new_record?
        end
      }
      associations.each do |association|
        association.order_errors.each {|order_error|   errors.add_to_base(order_error) }
        association.errors.each do |attribute, message| errors["#{association.class.name}.#{attribute}"] << message end
      end
    end
  end

  def order_associations
    associations = [book_record]
    is_member? and associations << member << member_card or associations << non_member
    !coaches.blank? and (associations += coaches)
    associations
  end


  def auto_generate_coaches_items
    OrderItem.order_coaches(self)
  end

  def auto_generate_book_record_item
    OrderItem.order_book_record(self)
  end

  #add to cart
  def order_goods(goods)
    goods = [goods] unless goods.is_a?(Array)
    if (invalid_goods = goods.select{|good| !good.should_add_to_cart?(self) }).blank?
      goods.map { |good| OrderItem.order_good(self, good)  }
    else
      invalid_goods.each do |good|
        good.errors.each do |attribute, message| errors["Good.#{attribute}"] << message end
      end
      []
    end
  end



  def cancel_bookrecord
    book_record.try(:cancle) 
  end

  def do_agent(new_order)
    new_book_record = new_order.book_record
    new_book_record.original_book_reocrd = book_record
    if book_record.is_not_overlap_with?(new_book_record)
      #do nothing,a new book record
    elsif book_record.is_more_then?(new_book_record)
      split_to_left_and_right(new_order)
    elsif book_record.less_or_equle_then?(new_book_record)
      destroy
    else
      book_record.do_agent(new_order)
      book_record_item.do_agent if book_record_item
      coach_items.each {|coach_item| coach_item.do_agent} unless coach_items.blank?
    end
  end

  def split_to_left_and_right(new_order)
    if book_record.is_more_then?(new_order.book_record)
      clone_left(new_order)
      clone_right(new_order)
      destroy
    end
  end

  def clone_left(new_order)
    clone_as_new(new_order,true)
  end

  def clone_right(new_order)
    clone_as_new(new_order,false)
  end

  def clone_as_new(new_order,left = true)
    order = Order.new(attributes.except(:book_record_id,:id))
    [:coache,:non_member,:member,:member_card].each do |association_method|
      association = send(association_method) and order.send("#{association_method}=",association)
    end
    time_spen = (left ? {:end_hour => new_order.start_hour} : {:start_hour => new_order.end_hour})
    book_attributes = book_record.attributes.except(:id).merge(time_spen)
    order.book_record_attributes = book_attributes
    order.operation = :agent
    order.book_record.original_book_reocrd = book_record
    order.book_record.status = BookRecord::Status_Agent
    order.save!
  end


  def is_advanced_order?
    !!advanced_order
  end

  def is_order_use_zige_card?
    is_member? && member_card.card.is_zige_card?
  end

  def amount
    balance.real_amount
  end

  def book_record_amount
    is_member? && member_card.card.is_counter_card? ? hours : book_record_item.amount
  end

  def product_amount
    p_amount = product_items.map(&:amount).sum
    p_amount += coach_items.map(&:amount).sum unless coach_items.blank?
    p_amount
  end

  def total_amount
    self.product_amount + self.book_record_amount
  end

  def can_balance?
    activated?
  end

  def do_balance
    self.operation = :balance
    member_card.do_balance(self) if is_member?
    book_record.balance  if book_record
    self.updating = false
    save
  end 

  def balance_record
    @balance_record ||= Balance.find_by_order_id(id)
  end

  def has_bean_balanced?
    self.balance.paid?
  end

  def should_use_card_to_balance_goods?
    is_member? && !member_card.card.is_counter_card? && member_card.card.is_consume_goods?
  end

  def order_member
    is_member? ? member : non_member
  end

  def member_card_number
    is_member? ? member_card.card_serial_num : "散客"
  end

  def advanced_order?
    !!advanced_order
  end

  def extra_fee_for_no_member
    return 0 if self.is_member? or self.non_member.nil?
    return self.total_amount - self.non_member.earnest 
  end


  def expired?
    Time.now > court_book_record.start_time
  end

  def status_desc
    desc = case
           when  booked? 
             expired? ? "已预订（过期）" : "预订"
           when  balanced?    then   "已结算"
           when  to_be_sold?     then
             expired? ? "停止代买" : "代卖中"
           when  actived?      then   "开打中"
           else "过期"
           end
    desc
  end

  def status_color
    color = case
            when  booked?         then  "color01"
            when  balanced?       then  "color05"
            when  to_be_sold?     then  "color04"
            when  activated?        then  "color03"
            else "color02"
            end
    color
  end
  end
