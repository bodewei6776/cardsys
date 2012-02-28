# -*- encoding : utf-8 -*-
class Coach < ActiveRecord::Base
  include HashColumnState
  include HasPinyinColumn

  set_pinyin_field :pinyin_name, :name

  validates :name, :presence => {:message => "名称不能为空！"}
  validates :cert_num, :uniqueness => {:on => :create, :message => '证件号已经存在！', :if => Proc.new { |coach|  !coach.cert_num.blank? }}#证件号唯一
  validates :telephone, :presence => {:message => "联系电话不能为空！"}#, :uniqueness => {:if => Proc.new { |coach|  !coach.telephone.blank? }, :message => "联系电话已经被使用了！"}
  validates :telephone, :format => {:with =>/^0{0,1}(13[0-9]|15[0-9])[0-9]{8}$/, :if => Proc.new { |coach|  !coach.telephone.blank? }, :message => '联系电话格式无效！'}
  validates :email, :format => {:with =>/^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/, :allow_blank => true,:message => '邮箱格式不正确！'}

  has_many :book_records, :as => :resource

  before_save :geneate_pinyin_name

  def amount(order_item)
    fee * order_item.quantity
  end

  private
  def coache_items_in_time_span(order)
    OrderItem.coache_items_in_time_span(order)
  end
end
