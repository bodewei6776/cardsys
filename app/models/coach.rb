class Coach < ActiveRecord::Base
  validates :name, :presence => {:message => "名称不能为空！"}
  validates :cert_num, :uniqueness => {:on => :create, :message => '证件号已经存在！', :if => Proc.new { |coach|  !coach.cert_num.blank? }}#证件号唯一
  validates :telephone, :presence => {:message => "联系电话不能为空！"}#, :uniqueness => {:if => Proc.new { |coach|  !coach.telephone.blank? }, :message => "联系电话已经被使用了！"}
  validates :telephone, :format => {:with =>/^0{0,1}(13[0-9]|15[0-9])[0-9]{8}$/, :if => Proc.new { |coach|  !coach.telephone.blank? }, :message => '联系电话格式无效！'}
  validates :email, :format => {:with =>/^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/, :allow_blank => true,:message => '邮箱格式不正确！'}


  after_create :set_default_status

  def set_default_status
    self.update_attribute(:status, 1)
  end


  def coach_status_str
    (self.status == 1) ? "正常" : "禁用"
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
