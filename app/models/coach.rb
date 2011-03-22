class Coach < ActiveRecord::Base
  
  include CoacheOrder

  ##default_scope where({:catena_id => current_catena.id})
  # file_column :portrait, :magick =>{:versions=>{"thumb" => "60x60", "medium" => "150x240"}}

  validates :name, :presence => {:message => "名称不能为空！"}
  validates :cert_num, :uniqueness => {:on => :create, :message => '证件号已经存在！', :if => Proc.new { |coach| !coach.cert_num.nil? && !coach.cert_num.blank? }}#证件号唯一
  validates :telephone, :presence => {:message => "联系电话不能为空！"}, :uniqueness => {:if => Proc.new { |coach| !coach.telephone.nil? && !coach.telephone.blank? }, :message => "联系电话已经被使用了！"}
  validates :telephone, :format => {:with =>/^0{0,1}(13[0-9]|15[0-9])[0-9]{8}$/, :if => Proc.new { |coach| !coach.telephone.nil? && !coach.telephone.blank? }, :message => '联系电话格式无效！'}
  validates :email, :format => {:with =>/^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/, :allow_blank => true,:message => '邮箱格式不正确！'}

  #before_create :set_catena_id

  scope :default_coaches,where(:status => Const::NO)

  def set_catena_id
    self.catena_id = current_catena.id
  end

  def coach_status_str
    "正常"
  end
  
  #TODO
  def amount(order_item)
    fee*order_item.quantity
  end
    
end
