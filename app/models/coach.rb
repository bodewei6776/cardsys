require 'pinyin/pinyin'
class Coach < ActiveRecord::Base
  STATE_MAP = {"enabled" => "正常", "disabled" => "禁用"}

  validates :name, :presence => {:message => "名称不能为空！"}
  validates :cert_num, :uniqueness => {:on => :create, :message => '证件号已经存在！', :if => Proc.new { |coach|  !coach.cert_num.blank? }}#证件号唯一
  validates :telephone, :presence => {:message => "联系电话不能为空！"}#, :uniqueness => {:if => Proc.new { |coach|  !coach.telephone.blank? }, :message => "联系电话已经被使用了！"}
  validates :telephone, :format => {:with =>/^0{0,1}(13[0-9]|15[0-9])[0-9]{8}$/, :if => Proc.new { |coach|  !coach.telephone.blank? }, :message => '联系电话格式无效！'}
  validates :email, :format => {:with =>/^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/, :allow_blank => true,:message => '邮箱格式不正确！'}

  scope :enabled, where(:state => "enabled")


  has_many :book_records, :as => :resource

  before_save :geneate_pinyin_name

  def geneate_pinyin_name
    pinyin = PinYin.new
    self.pinyin_name = pinyin.to_pinyin(self.name) if self.name
  end

  def amount(order_item)
    fee * order_item.quantity
  end


  def order_errors
    @order_errors ||= []
  end

  def clear_order_errors
    order_errors.clear
  end

  def is_ready_to_order?(order)
    clear_order_errors
    unless (exist_coaches = coache_items_in_time_span(order)).blank?
      order_errors << I18n.t('order_msg.coache.conflict',:coach_name => exist_coaches.map(&:item).map(&:name).join(','),
      :start_hour => order.start_hour,:end_hour => order.end_hour)
    end
  end

  private
  def coache_items_in_time_span(order)
    OrderItem.coache_items_in_time_span(order)
  end
end
