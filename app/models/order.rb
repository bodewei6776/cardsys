# -*- encoding : utf-8 -*-
require 'digest/sha1'
class Order < ActiveRecord::Base
  OPMAP = { "activate"         => "开场",
            "want_sell"        => "申请代卖",
            "all_cancel"       => "连续取消",
            "cancel_want_sell" => "取消代卖",
            "cancel"           => "取消预订" }
  include Authenticateable
  belongs_to  :user
  belongs_to  :members_card
  belongs_to  :advanced_order
  has_many    :balances, :dependent => :destroy
  has_one     :court_book_record, :dependent => :destroy
  has_many    :coach_book_records, :dependent => :destroy
  has_many    :order_items, :dependent => :destroy
  belongs_to  :member
  has_one     :non_member
  belongs_to  :advanced_order

  has_many :logs, :as => :item

  validates  :members_card_id, :presence => { :message => "请选择会员卡" }, :if => proc { |order| order.is_member? }
  validates  :member_id, :presence => { :message => "请选择会员" }, :if => proc { |order| order.is_member? }
  validate   :coach_valid
  validate   :card_avaliable_in_time_span
  validate   :end_date_later_than_today

  accepts_nested_attributes_for :court_book_record
  accepts_nested_attributes_for :coach_book_records
  accepts_nested_attributes_for :non_member, :reject_if => proc { |non_member| non_member[:is_member] == "1" || non_member[:is_member] == "true" }
  attr_accessor :coach_ids, :split_from_other, :possible_batch_order
  after_save :save_order_items_for_court_and_coaches

  before_create :assign_batch_number
  after_create :batch_order

  delegate :alloc_date, :end_hour, :start_hour, :hours, :start_time, :end_time, :to => :court_book_record

  validation_conditions << proc {|obj|  obj.new_record? && !obj.split_from_other }
  validation_conditions << proc {|obj|  obj.state == "to_be_sold" && obj.state_was == "booked" }
  validation_conditions << proc {|obj|  obj.state == "canceld" }
  validation_conditions << proc {|obj|  obj.changed? && obj.state == obj.state_was }

  def save_order_items_for_court_and_coaches
    return unless court_book_record
    court_book_record_order_item = self.order_items.find_or_initialize_by_item_type_and_item_id("CourtBookRecord", court_book_record.id)
    court_book_record_order_item.update_attributes(:quantity => court_book_record.hours,
                                                   :total_count => court_book_record.hours,
                                                   :total_money_price => court_book_record.price(self.members_card),
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

  def assign_batch_number
    self.batch_number = Digest::SHA1.hexdigest Time.now.to_s if self.batch_number.blank?
  end

  def end_date_later_than_today
    self.errors.add(:end_date, "结束日期至少大于当天") if self.end_date and self.end_date < self.order_date
  end

  def batch_order
    return true unless self.possible_batch_order
      
    self.class.wdate_between(self.order_date, self.end_date).each do |date|
      new_order = Order.new(self.attributes.except("id"))
      # prevent for futher copy, orelse this may lead to loop
      new_order.possible_batch_order = false
      new_order.court_book_record = CourtBookRecord.new(self.court_book_record.attributes.except("id").merge(:alloc_date => date))
      self.coach_book_records.each do |cbr| 
        new_order.coach_book_records << CoachBookRecord.new(cbr.attributes.except("id").merge(:alloc_date => date))
      end

      new_order.is_advance_order = true
      self.update_column(:is_advance_order, true)
      self.update_column(:batch_number, self.batch_number)
      new_order.save(:validate => false)
    end
  end

  def all_update_attributes(order_attributes)
    self.update_attributes(order_attributes)
    self.advance_order_siblings(self.alloc_date).each do |element|
      order_attributes["court_book_record_attributes"]["id"] = element.court_book_record.id
      order_attributes["court_book_record_attributes"]["alloc_date"] = element.alloc_date
      element.update_attributes order_attributes
    end

  end

  def self.wdate_between(begin_date, end_date)
    days = []
    offset_date = begin_date + 7.days

    while( offset_date <= end_date ) do
      days.push offset_date
      offset_date += 7.day
    end

    days
  end

  def card_avaliable_in_time_span
    return true unless self.members_card
    return true unless self.court_book_record
    self.errors.add(:members_card_id, "此卡已经被锁定，解锁后预订") if self.members_card.disabled?
    self.errors.add(:members_card_id, "卡在此时段不可用") unless (self.court_book_record.period_prices & self.members_card.card.period_prices).present?
  end

  def replace_by(order_attributes)
    new_order = Order.new(order_attributes)
  end

  def coach_valid
    return true if coach_ids.blank?
    coach_book_records.each do |c|
      c.start_hour = start_hour 
      c.end_hour = end_hour
      c.alloc_date = alloc_date
      errors.add(:base, c.conflict_book_record.to_s + "已经被预约") if c.conflict?
    end
  end

  def coach_order_items
    self.order_items.where(:item_type => "CoachBookRecord")
  end


  state_machine  :initial => :booked do
    after_transition :on => :cancel , :do => :destroy
    after_transition :on => :all_cancel , :do => :advance_destroy

    event :activate do
      transition :booked => :activated
    end

    event :want_sell do
      transition :booked => :to_be_sold#, :if => lambda { |o| o.is_member? }
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


    event :all_cancel do
      transition [:to_be_sold, :booked] => :all_canceld
    end

    event :balance do
      transition [:cart_loaded, :activated] => :balanced
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
        cbr = CoachBookRecord.new
        cbr.resource_type = "Coach"
        cbr.resource_id =  c.id
        cbr
      end
    end

    def advance_destroy
      self.advance_order_siblings.collect(&:destroy)
      self.destroy
    end

    def can_sell?
      to_be_sold?
    end

    def can_cancel?
       Setting.can_cancel_time_before_activate.from_now < court_book_record.start_time && (!balanced? && !activated?)
    end

    def can_want_sell?
      booked?
    end

    def can_change?
      not self.to_be_sold? and not self.balanced?
    end

    def can_cancel_want_sell?
      to_be_sold?
    end

    def can_cancel_all?
       is_advance_order? && Setting.can_cancel_time_before_activate.from_now < court_book_record.start_time && (not balanced? && !activated?)
    end

    def can_update_all?
      booked? && is_advance_order?
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
        possible_ways = []
        if members_card.left_times > 0
          possible_ways << "counter"
        end
        if members_card.left_fee > 0
          possible_ways << "card"
        end
      else
        possible_ways = []
      end
      possible_ways = possible_ways | ["cash", "pos", "bank", "guazhang", "check"]
      result = []
      possible_ways.each{ |k| result << [Balance::BALANCE_WAYS[k], k] }
      result
    end

    def ought_to_activate?
      (self.booked? || self.to_be_sold?) && Time.now > self.end_time
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
      goods.map { |good| self.order_items.build({:item_type => Good, :item_id => good.id})  }
    end

    def hour_range
      self.start_hour..self.end_hour
    end

    def split(order_attributes)
      new_order = Order.new(order_attributes.deep_except('id'))
      new_order.state = "booked"
      new_order.end_date = Date.today
      new_order.split_from_other = true
      #  begin
      Order.transaction do
        # 无重叠
        if new_order.hour_range.overlap_window_size(self.hour_range).zero?
          new_order.errors.add(:base, "时间段与当前预订没有重叠")
          raise Exception
          # 新订单时间覆盖当前时间段
        elsif new_order.hour_range.overlap_window_size(self.hour_range) == self.hours
          self.destroy
          new_order.save!
          # 小于当前时间段
        elsif self.hour_range.include? new_order.hour_range
          if self.start_hour == new_order.start_hour
            self.change_start_hour_to(new_order.end_hour)
          elsif self.end_hour == new_order.end_hour
            self.change_end_hour_to(new_order.start_hour)
          else
            self.change_end_hour_to(new_order.start_hour)
            cloned_order = clone_new_order
            cloned_order.change_start_hour_to(new_order.end_hour)
          end

          new_order.save!
          # 部分重叠
        elsif new_order.hour_range.overlap_window_size(self.hour_range) < self.hours
          self.start_hour < new_order.start_hour ? self.change_end_hour_to(new_order.start_hour) : self.change_start_hour_to(new_order.end_hour) 
          new_order.save!
        end
      end

      true
      #  rescue Exception => e
      #    puts e
      #    return false
      #  end

      new_order
    end

    def change_start_hour_to(new_start_hour)
      self.court_book_record.update_attributes(:start_hour => new_start_hour)
      self.coach_book_records.each do |element|
        element.update_attributes(:start_hour => new_start_hour)
      end
    end

    def change_end_hour_to(new_end_hour)
      self.court_book_record.update_attributes(:end_hour => new_end_hour)
      self.coach_book_records.each do |element|
        element.update_attributes(:end_hour => new_end_hour)
      end
    end

    def clone_new_order
      order = Order.new(self.attributes.except("id"))
      order.court_book_record = CourtBookRecord.new(self.court_book_record.attributes.except("id"))
      self.coach_book_records.each do |element|
        order.coach_book_records  << CoachBookRecord.new(element.attributes.except("id"))
      end
      order.save
      order
    end

    def is_order_use_zige_card?
      is_member? && members_card.card.is_zige_card?
    end

    def amount
      balance.real_amount
    end

    def book_record_amount
      is_member? && members_card.card.is_counter_card? ? hours : book_record_item.amount
    end

    def product_items
      self.order_items.select{|oi| Good === oi.item} 
    end

    def product_amount
      p_amount = product_items.map(&:amount).sum
      p_amount += coach_items.map(&:amount).sum unless coach_items.blank?
      p_amount
    end

    def total_amount
      self.product_amount + self.book_record_amount
    end

    def can_consume_goods?
      members_card && members_card.can_consume_goods? 
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
             when  booked?  then           expired? ? "已预订（过期）" : "预订"
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

    def return_money
      self.balances.each do |balance|
        next unless ["counter", "card"].include? balance.balance_way 
        if balance.balance_way == "counter"
          self.members_card.update_column(:left_times, self.members_card.left_times + balance.final_price.to_i)
        end

        if balance.balance_way == "card"
          self.members_card.update_column(:left_fee, self.members_card.left_fee + balance.final_price)
        end
      end
      true
    end

    def member_name
      begin
        is_member? ? member.name : non_member.name
      rescue 
        ""
      end
    end

    def advance_order_siblings(from_date = nil)
      from_date ||= self.alloc_date
      Order.all(:conditions => ["book_records.alloc_date > :from_date && batch_number = :batch_number",
                { :from_date => from_date, :batch_number => self.batch_number}], :include => :court_book_record)
      #Order.find_by_sql("SELECT `book_records`.* FROM `book_records` WHERE " + 
      #                  "`book_records`.`resource_id` = 1 AND `book_records`.`resource_type` = 'Coach'" + 
      #                  "AND `book_records`.`alloc_date` = '2012-05-20' AND (order_id != 616)" +
      #                  "AND (start_hour < 8 AND end_hour > 7) LIMIT 1")
    end


    end
