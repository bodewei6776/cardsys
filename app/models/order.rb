class Order < ActiveRecord::Base
  has_many    :order_items,:dependent => :destroy
  has_many    :balance_items
  belongs_to  :card
  belongs_to  :user
  has_many    :coach_items,:class_name => 'OrderItem',:conditions => "item_type=#{OrderItem::Item_Type_Coache} "
  has_one     :book_record_item,:class_name => 'OrderItem',:conditions => "item_type=#{OrderItem::Item_Type_Book_Record}"
  has_many    :product_items,:class_name => 'OrderItem',:conditions => "item_type=#{OrderItem::Item_Type_Product}"
  has_one :balance, :dependent => :destroy

  validates  :card_id,:member_id,:book_record_id,:presence => {:message => "信息不完整，请补充完所需要的信息"}
  validate do |order|
    order.validates_assocations
  end

  after_create :generate_balance
  after_save    :update_balance
  before_create :init_attributes
  before_save   :auto_save_order_associations
  after_save    :auto_generate_coaches_items
  after_create  :auto_generate_book_record_item

  attr_accessor :coach_id,:operation,:updating
  attr_accessor :coach,:non_member,:member,:member_card,:book_record
  
  scope :waiting_balance, where(:paid_stauts => Const::NO)
  scope :balanced,where(:paid_stauts => Const::YES)

  delegate :record_date,:end_hour,:start_hour,:hours,:to => :book_record

  def operation
    @operation.blank? ? BookRecord.default_operation : @operation.to_sym
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

  def init_attributes
    self.order_time = DateTime.now
  end

  def auto_save_order_associations
    return unless book_record
    book_record.route_operation(operation) and (self.book_record_id = book_record.id)
    if is_member?
      self.member_id      = member.id
      self.member_name    = member.name
      self.card_id        = member_card.card_id
      self.member_card_id = member_card.id
    else
      if non_member.save!
        self.member_id      = non_member.id
        self.card_id        = 0
        self.member_name    = non_member.name
        self.member_card_id = non_member.id
      end
    end
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
      goods.map { |good| OrderItem.order_goolds(self,good)  }
    else
      invalid_goods.each do |good|
        good.errors.each do |attribute, message| errors["Good.#{attribute}"] << message end
      end
      []
    end
  end

                   

  def auto_destory_order_items
    OrderItem.delete_all(:order_id => id)
  end

  def destroy
    book_record.cancle if book_record
    auto_destory_order_items
    super
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
  
  
  def original_coaches
    new_record? || coach_items.blank? ? [] : coach_items.map(&:related_entry)
  end

  def coaches
    updating ? @coaches : original_coaches
  end

  def coaches=(cs)
    @coaches = cs
    @updating = true
  end

  def non_member
    return @non_member if new_record?
    @non_member ||= (!is_member? && member_id > 0 ? NonMember.find(member_id) : nil)||''
    @non_member.blank? ? nil : @non_member
  end

  def member
    return @member if new_record?
    @member ||= (is_member? && member_id > 0 ? Member.find(member_id) : nil) ||''
    @member.blank? ? nil : @member
  end

  def member_card
    return @member_card if new_record?
    @member_card ||= (is_member? && member_card_id > 0 ? MemberCard.find(member_card_id) : nil) ||''
    @member_card.blank? ? nil : @member_card
  end

  def book_record
    return @book_record if new_record?
    @book_record ||=( book_record_id > 0 ?  BookRecord.find(book_record_id) : nil) || ''
    @book_record.blank? ? nil : @book_record
  end
  
  def is_member?
    self.member_type == Const::YES
  end

  def coach_attributes=(coach_attri)
    unless coach_attri[:id].blank?
      @coaches = coach_attri[:id].uniq.delete_if{|c_id|c_id.to_i <= 0 }.map{|coach_id| Coach.find(coach_id) }
    end
    @updating = true
  end

  def book_record_attributes=(book_attributes)
    if new_record?
      @book_record = BookRecord.new(book_attributes)
    else
      @book_record = BookRecord.find(book_attributes[:id])
      @book_record.attributes=book_attributes
    end
    @updating = true
  end

  def non_member_attributes=(non_member_attributes)
    unless is_member?
      if new_record?
        @non_member = NonMember.new(non_member_attributes)
      else
        @non_member = NonMember.find(non_member_attributes[:id])
        @non_member.attributes=non_member_attributes
      end
    end
    @updating = true
  end
  
  def member_attributes=(member_attributes)
    if is_member?
      @member = Member.find(member_attributes[:id]) if member_attributes[:id].to_i > 0
    end
    @updating = true
  end

  def member_card_attributes=(member_card_attributes)
    if is_member? && !member_card_attributes[:id].blank?
      @member_card = MemberCard.find_by_card_serial_num(member_card_attributes[:id])
    end
    @updating = true
  end
  
  def is_advanced_order?
    parent_id.to_i > 0
  end

  def is_order_use_zige_card?
    is_member? && member_card.card.is_zige_card?
  end
  
  def advanced_order
    @advanced_order ||= (is_advanced_order? ? AdvancedOrder.find(parent_id) : '')
    @advanced_order.blank? ? nil : @advanced_order
  end
  
  def amount
    OrderItem.except_book_records.where(:order_id => id).map(&:amount).sum
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
    
  def do_balance
    self.operation = :balance
    member_card.do_balance(self) if is_member?
    book_record.do_balance  if book_record
    order_items.each{|order_item| order_item.do_balance }
    self.paid_stauts = Const::YES
    self.updating =false
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

  def extra_fee_for_no_member
    return 0 if self.is_member? or self.non_member.nil?
    return self.total_amount - self.non_member.earnest 
  end

  def order_and_order_after
    self.advanced_order.orders.select{|o| o.book_record.record_date >= self.book_record.record_date}
  end

  def generate_balance
    self.balance = Balance.new(:status => Const::NO)
  end

  def update_balance
    self.balance.update_amount
  end

  
end
