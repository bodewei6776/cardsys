# -*- encoding : utf-8 -*-
class NonMember < ActiveRecord::Base
  include HasPinyinColumn
  set_pinyin_field :name_pinyin, :name

  validates :telephone, :presence => {:message => I18n.t('order_msg.non_member.mobile_no_presence')}, :if => proc {|nm|  !nm.is_member? }
  validates :telephone, :format => {:with =>/^(?:0{0,1}(13[0-9]|15[0-9])[0-9]{8})|(?:[-0-9]+)$/,
    :message => I18n.t('order_msg.non_member.invalid_mobile_format')}, :allow_blank => true

  validates :earnest,:presence => {:message => "定金为必填项"},:numericality => true, :allow_blank => true, :if => proc {|nm| !nm.is_member?}
  validates :name, :presence => {:message => "请填写散客姓名"}, :if => proc {|nm| !nm.is_member? }

  belongs_to :order

  attr_accessor :is_member

  def is_member?
    is_member == "true" || is_member == "1"
  end

  def is_ready_to_order?(order)
    clear_order_errors
    book_record = order.book_record
    date,start_hour,end_hour = book_record.record_date,book_record.start_hour,book_record.end_hour
    court_amount = book_record.court.calculate_amount_in_time_span(date,start_hour,end_hour)
  end
end
