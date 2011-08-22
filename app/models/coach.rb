class Coach < ActiveRecord::Base
  
  include CoacheOrder

  validates :name, :presence => {:message => "名称不能为空！"}
  validates :cert_num, :uniqueness => {:on => :create, :message => '证件号已经存在！', :if => Proc.new { |coach|  !coach.cert_num.blank? }}#证件号唯一
  validates :telephone, :presence => {:message => "联系电话不能为空！"}#, :uniqueness => {:if => Proc.new { |coach|  !coach.telephone.blank? }, :message => "联系电话已经被使用了！"}
  validates :telephone, :format => {:with =>/^0{0,1}(13[0-9]|15[0-9])[0-9]{8}$/, :if => Proc.new { |coach|  !coach.telephone.blank? }, :message => '联系电话格式无效！'}
  validates :email, :format => {:with =>/^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/, :allow_blank => true,:message => '邮箱格式不正确！'}


  scope :default_coaches,where(:status => Const::YES)

  after_create :set_default_status
  def set_default_status
    self.update_attribute(:status, 1)
  end

  def set_catena_id
    self.catena_id = current_catena.id
  end

  def coach_status_str
    (self.status == 1) ? "正常" : "禁用"
  end
  
  #TODO
  def amount(order_item)
    fee*order_item.quantity
  end
    
end
