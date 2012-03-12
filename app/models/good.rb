# -*- encoding : utf-8 -*-
class Good < ActiveRecord::Base
  include HashColumnState
  include HasPinyinColumn

  set_abbr_field :pinyin_abbr, :name

  belongs_to :category,:foreign_key => "good_type"

  validates :name, :presence => {:message => "名称不能为空！"}, :uniqueness => {:on => :create, :message => '名称已经存在！', 
    :if => Proc.new { |member| !member.name.nil? && !member.name.blank? }}
  validates :purchasing_price, :numericality => {:message => "入库价格必须为数字！"}
  validates :price, :numericality => {:message => "零售价格必须为数字！"}
  validates :count_back_stock, :numericality => {:message => "初次入库数必须为数字！"}
  validates :count_back_stock_in, :numericality => {:message => "新入大库数必须为数字！", :allow_blank => true}
  validates :count_back_stock_out, :numericality => {:message => "新出大库数必须为数字！", :allow_blank => true}
  validates :count_front_stock_in, :numericality => {:message => "新入小库数必须为数字！", :allow_blank => true}
  validates :count_front_stock_out, :numericality => {:message => "新出小库数必须为数字！", :allow_blank => true}

  has_many :order_items, :as => :item
  
  attr_accessor :order_count

  def good_type_in_chinese
    self.category.name
  end

  def amount(order_item)
    price * order_item.quantity
  end
  
  def add_to_cart
    self.count_total_now   -= self.order_count
    self.count_front_stock -= self.order_count
    self.count_front_stock_out ||= 0
    self.count_front_stock_out += self.order_count
    self.sale_count += self.order_count
    save
  end
  
end
