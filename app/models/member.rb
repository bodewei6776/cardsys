require 'pinyin/pinyin'
class Member < ActiveRecord::Base

  STATE_MAP = {"enabled" => "启用",
              "disabled" => "禁用"}

  scope :autocomplete_for, lambda {|name| 
    where("state= 'enabled' and (LOWER(name_pinyin) LIKE :member_name or LOWER(name) like :member_name or LOWER(pinyin_abbr) like :member_name)", {:member_name => "#{name.downcase}%"}).limit(10).order("pinyin_abbr ASC") }

    
  scope :enabled, where(:state => "enabled")

  has_many :orders
  has_one  :member_card_granter,:foreign_key => "granter_id"
  has_many :member_cards


  validates :name, :presence => {:message => "名称不能为空！"}
  validates :mobile, :format => {:with =>/^0{0,1}(13[0-9]|15[0-9]|18[0-9])[0-9]{8}$/,:message => '手机号为空或者手机号格式不正确！', :allow_blank => false}
  validates :telephone, :numericality => {:only_integer => true, :message => "电话号码必须为数字！", :allow_blank => true}, :length => {:minimum => 8, :maximum => 11, :message => "电话必须大于8位小于11位！", :allow_blank => true}
  validates :email, :format => {:with =>/^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/, :allow_blank => true,:message => '邮箱格式不正确！'}
  validates :cert_num, :uniqueness => {:on => :create, :message => '证件号已经存在！', :if => Proc.new { |member| !member.cert_num.nil? && !member.cert_num.blank? }}#证件号唯一
  validates_with MyValidator

  before_save :geneate_name_pinyin

  def geneate_name_pinyin
    pinyin = PinYin.new
    self.name_pinyin = pinyin.to_pinyin(self.name) if self.name
    self.pinyin_abbr = pinyin.to_pinyin_abbr(self.name) if self.name
  end

  def card_serial_nums
    return "尚未开通" if self.all_member_cards.blank?
    self.all_member_cards.collect(&:card_serial_num).join(",")
  end

  def generate_member_card?(card)
    return true if card.nil?
    MemberCard.exists?({:member_id => self.id, :card_id => card.id})
  end

  def has_card?
    all_member_cards.present?
  end

  def generate_member_card_granters
    granter_ids = []
    mcgs = MemberCardGranter.where(:member_id => self.id)
    for mcg in mcgs
      granter_ids << mcg.granter_id
    end
    granter_names = []
    Member.where(["id IN(?)", granter_ids]).where(:catena_id => self.catena_id).each { |member| granter_names << member.name }
    granter_names
  end

  def grantee
    Member.find_by_id(MemberCardGranter.where(:granter_id => id).first.member_id)
  end

  def is_granter(granter_id, card_id)
    !MemberCardGranter.where(:member_id => self.id).where(:member_card_id => card_id).where(:granter_id => granter_id ).first.nil?
  end

  def is_granter_of_card(card_id)
    !MemberCardGranter.where(:granter_id=> self.id).where(:member_card_id => card_id).blank?
  end


  def all_members_cards
    if is_member?
      MembersCard.where(:member_id => id)
    else
      granters = MemberCardGranter.where(:granter_id => id).all
      MembersCard.where("id IN (#{granters.map(&:member_card_id).join(',')})")
    end
  end

  def member_card_left_times
    self.all_member_cards.sum('left_times')
  end

  def member_card_left_fees
    self.all_member_cards.sum('left_fee')
  end

  def member_consume_amounts
    self.orders.inject(0){|s,o| s + (o.amount || 0)} 
  end

  def latest_comer_date
    self.orders.last.try(:order_time).try(:to_chinese_short) || "无"
  end

  def recharge_fees
    RechargeRecord.where(:member_id => self.id).sum('recharge_fee')
  end

  def recharge_times
    RechargeRecord.where(:member_id => self.id).sum('recharge_times')
  end

  def balance_times
    0
  end

  def use_card_price_amount
    0
  end

  def use_cash_amount
  #  self.balances.balanced.where( ["(balance_way = ?)",Balance::Balance_Way_Use_Cash]).inject(0){|s,b| s + b.book_record_real_amount}
  end

  def use_card_amount
   # self.balances.balanced.where( ["(balance_way = ?)",Balance::Balance_Way_Use_Card]).inject(0){|s,b| s + b.book_record_real_amount}
  end

  def is_member?
    !granter?
  end


  def order_errors
    @order_errors ||= []
  end

  def clear_order_errors
    order_errors.clear
  end
  
  def is_ready_to_order?(order)
    clear_order_errors
    unless has_card?
      order_errors << I18n.t('order_msg.member.non_card')
    end
 end
end
