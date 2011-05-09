require 'pinyin/pinyin'
class Good < ActiveRecord::Base
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


  
  before_create  :geneate_name_pinyin
  attr_accessor :order_count

  scope :valid_goods,where(:status => 0)

  def geneate_name_pinyin
    pinyin = PinYin.new
    self.pinyin_abbr = pinyin.to_pinyin_abbr(self.name) if self.pinyin_abbr.blank?
  end

  def amount(order_item)
    price*order_item.quantity
  end
  
  def increment_sale_count
    self.class.execute("UPDATE sale_count = sale_count+1 WHERE id=#{self.id}")
  end
  
  def should_add_to_cart?(order)
    if count_front_stock.to_i < order_count
      errors[:base] << I18n.t('order_msg.good.count_front_stock',
      {:name => self.name,:count => count_front_stock,:back_count => count_back_stock})
      return false
    end
    return true
  end  
  
  def sale(count)
    set_sql = ''
    set_sql << " count_back_stock_out ＝ count_back_stock_out ＋ #{count} "
    set_sql << " ,count_front_stock = CASE count_front_stock-#{count} >= 0 THEN count_front_stock-#{count} ELSE 0 END "
    set_sql << ",sale_count = sale_count + #{count}"
    self.class.execute("UPDATE goods SET #{set_sql} WHERE id=#{self.id}")
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
