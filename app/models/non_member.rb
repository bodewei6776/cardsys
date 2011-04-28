require 'pinyin/pinyin'
class NonMember < ActiveRecord::Base

  include NonMemberOrder

  has_one :order,:foreign_key => 'member_id',:conditions => "member_type=#{Const::NO}"
  
  validates :telephone, :presence => {:message => I18n.t('order_msg.non_member.mobile_no_presence')}
  validates :telephone, :format => {:with =>/^(?:0{0,1}(13[0-9]|15[0-9])[0-9]{8})|(?:[-0-9]+)$/,
    :message => I18n.t('order_msg.non_member.invalid_mobile_format')}

  validates :earnest,:presence => {:message => "定金为必填项"},:numericality => true

  before_save :geneate_name_pinyin

  def geneate_name_pinyin
    pinyin = PinYin.new
    self.name_pinyin = pinyin.to_pinyin(self.name) if self.name_pinyin.blank?
  end

end
