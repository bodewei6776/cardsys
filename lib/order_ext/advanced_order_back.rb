# class AdvancedOrder
#   
#   include ActiveModel::Validations
#   
#   attr_accessor :court_id,:wday,:start_date,:end_date
#   attr_accessor :start_hour,:end_hour,:member_card_id,:member_id
#   
#   validates :start_hour, :numericality => {:message => "开始时间必须为整数"},:presence => {:message => "请选择开始时间"}
#   validates :end_hour, :numericality => {:message => "结束时间必须为整数"},:presence => {:message => "请选择结束时间"}
#   validates :start_date,:end_date,:presence => {:message => "请选择开始结束日期"}
#   validates :wday,:presence => {:message => "请选择选择星期"},
#   :numericality => {:greater_than_or_equal_to => 1,:less_than_or_equal_to => 7,:message => "请选择正确的星期" }
#   validates :court_id,:presence => {:message => "请选择场地"}
#   
#   validate :order_business_validate 
#     
#   def initialize(attributes = {})
#     attributes.keys.each do |attr|
#       send("#{attr}=",attributes[attr]) if respond_to?("#{attr}=")
#     end
#   end
#   
#   def start_date=(date_str)
#     @start_date = Date.parse(date_str) rescue nil
#   end
#   
#   def end_date=(date_str)
#     @end_date = Date.parse(date_str) rescue nil
#   end
#   
#   def order_business_validate
#     if member.blank? || member_card.blank?
#       errors[:base] << I18n.t('order_msg.advanced_order.member')
#     else
#       errors[:base] << I18n.t('order_msg.advanced_order.conflict') if exist_conflict_book_record?
#       orders = orders_between_start_and_end_date
#       if invalid_order = orders.find{|order| !order.valid? }
#         invalid_order.errors.each do |attribute, message| 
#           errors[:base] << message
#         end
#       end
#       unless member_card.should_advanced_order?(start_hour,end_hour)
#         errors[:base] << I18n.t('order_msg.advanced_order.non_advanced_order')
#       end
#     end
#   end
#   
#   def save(options={})
#     valid? and batch_order or false
#   end
#   
#   def batch_order
#     orders_between_start_and_end_date.each { |order|  order.save }
#   end
#   
#   def order_dates_between_start_and_end_date
#     (0...weeks_between_start_and_end_date).to_a.map { |wk|  realy_start_date + 7*wk}
#   end
#   
#   def weeks_between_start_and_end_date
#     start_cweek = start_wday > wday ? start_date.cweek + 1 : start_date.cweek
#     end_cweek   = end_wday < wday ? end_date.cweek - 1 : end_date.cweek
#     [end_cweek - start_cweek + 1,1].max
#   end
#   
#   def orders_between_start_and_end_date
#     @orders ||= order_dates_between_start_and_end_date.map { |record_date| 
#       order = Order.new
#       order.member = member
#       order.member_card = member_card
#       order.book_record  = new_book_record(record_date)
#       order.operation = :book
#       order
#     }
#   end
#   
#   def book_records_between_start_and_end_date
#     @orders.map(&:book_record)
#   end
#   
#   def realy_start_date
#     benchmark_date = start_wday > wday ? start_date + 7 : start_date
#     (wday - start_wday).days.since(benchmark_date)
#   end
#   
#   def realy_end_date
#     benchmark_date = end_wday < wday ? end_date - 7 : end_date
#     (end_wday - wday).days.ago(benchmark_date)
#   end
#   
#   def start_wday
#     start_date.wday == 0 ? 7 : start_date.wday
#   end
#   
#   def end_wday
#     end_date.wday == 0 ? 7 : end_date.wday
#   end
#   
#   def exist_conflict_book_record?
#     conflict_records = BookRecord.where(:court_id => court_id).where("WEEKDAY(record_date)=#{wday-1}").
#     where("record_date>='#{start_date}' AND record_date<='#{end_date}'").
#     where(["start_hour < :end_time AND end_hour > :start_time",{:start_time => start_hour,:end_time => end_hour}])
#     !conflict_records.first.blank?
#   end
#   
#   def wday
#     @wday.to_i
#   end
#   
#   def new_book_record(record_date)
#     book_record = BookRecord.new
#     book_record.status = BookRecord::Status_Default
#     book_record.record_date = record_date
#     book_record.start_hour  = start_hour
#     book_record.end_hour    =  end_hour
#     book_record.court_id    = court_id
#     book_record 
#   end
#   
#   def member
#     @member
#   end
#       
#   def member_attributes=(member_attributes)
#     puts member_attributes[:id].to_i > 0
#     if member_attributes[:id].to_i > 0
#        @member_id = member_attributes[:id]
#        @member = Member.find(member_attributes[:id])
#     end
#   end
#   
#   def member_card
#     @member_card
#   end
# 
#   def member_card_attributes=(member_card_attributes)
#     if member_card_attributes[:id].to_i > 0
#       @member_card_id = member_card_attributes[:id].to_i
#       @member_card = MemberCard.find(member_card_attributes[:id])
#     end
#   end
#   
# end