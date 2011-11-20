require 'pinyin/pinyin'
class NonMember < ActiveRecord::Base
  validates :telephone, :presence => {:message => I18n.t('order_msg.non_member.mobile_no_presence')}
  validates :telephone, :format => {:with =>/^(?:0{0,1}(13[0-9]|15[0-9])[0-9]{8})|(?:[-0-9]+)$/,
    :message => I18n.t('order_msg.non_member.invalid_mobile_format')}

  validates :earnest,:presence => {:message => "定金为必填项"},:numericality => true

  before_save :geneate_name_pinyin
  belongs_to :order

  def geneate_name_pinyin
    pinyin = PinYin.new
    self.name_pinyin = pinyin.to_pinyin(self.name) if self.name_pinyin.blank?
  end


  def order_errors
    @order_errors ||= []
  end

  def clear_order_errors
    order_errors.clear
  end

  def is_ready_to_order?(order)
    clear_order_errors
    book_record = order.book_record
    date,start_hour,end_hour = book_record.record_date,book_record.start_hour,book_record.end_hour
    court_amount = book_record.court.calculate_amount_in_time_span(date,start_hour,end_hour)
  end
end
