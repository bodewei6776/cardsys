require 'pinyin/pinyin'
class Member < ActiveRecord::Base

  scope :autocomplete_for, lambda {|name| where("status = '#{CommonResource::MEMBER_STATUS_ON}' and (LOWER(name_pinyin) LIKE :member_name or LOWER(name) like :member_name or LOWER(pinyin_abbr) like :member_name)", {:member_name => "#{name.downcase}%"}).limit(10).order("pinyin_abbr ASC") }


  def can_catena?
    false
  end

  include MemberOrder

  default_scope :order =>  'id desc'

  has_many     :member_cards
  has_many :orders
  has_many :balances
  has_one  :member_card_granter,:foreign_key => "granter_id"

  before_save :geneate_name_pinyin


  validates :name, :presence => {:message => "名称不能为空！"}
  #, :uniqueness => {:on => :create, :message => '名称已经存在！', :if => Proc.new { |member| !member.name.nil? && !member.name.blank? }}
  #  validates :mobile, :presence => {:message => "手机号不能为空！"}, :uniqueness => {:on => :create, :if => Proc.new { |member| !member.mobile.nil? && !member.mobile.blank? }, :message => "手机号已经被使用了！"}#手机号唯一
  validates :mobile, :format => {:with =>/^0{0,1}(13[0-9]|15[0-9]|18[0-9])[0-9]{8}$/,:message => '手机号为空或者手机号格式不正确！', :allow_blank => false}
  validates :telephone, :numericality => {:only_integer => true, :message => "电话号码必须为数字！", :allow_blank => true}, :length => {:minimum => 8, :maximum => 11, :message => "电话必须大于8位小于11位！", :allow_blank => true}
  validates :email, :format => {:with =>/^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/, :allow_blank => true,:message => '邮箱格式不正确！'}
  validates :cert_num, :uniqueness => {:on => :create, :message => '证件号已经存在！', :if => Proc.new { |member| !member.cert_num.nil? && !member.cert_num.blank? }}#证件号唯一

  # include my validator and validate the record
  #include ActiveModel::MyValidators
  validates_with MyValidator

  def geneate_name_pinyin
    pinyin = PinYin.new
    self.name_pinyin = pinyin.to_pinyin(self.name) if self.name#name_pinyin.blank?
    self.pinyin_abbr = pinyin.to_pinyin_abbr(self.name) if self.name#pinyin_abbr.blank?
  end

  def card_serial_nums
    if (self.member_cards.nil? || self.member_cards.length == 0)
      return "尚未开通"
    end
    sns = ""
    for card in self.member_cards
      sns.concat(",#{card.card_serial_num}")
    end
    return sns.slice(1,sns.length)
  end

  def generate_member_card?(card)
    !(MemberCard.where(:member_id => self.id).where(:card_id => card.id).first).nil?
  end

  def has_card?
    !member_cards.first.blank?
  end

  def generate_member_card_granters
    granter_ids = []
    mcgs = MemberCardGranter.where(:member_id => self.id)
    for mcg in mcgs
      granter_ids << mcg.granter_id
    end
    granter_names = []
    Member.where(["id IN(?)", granter_ids]).where(:catena_id => self.catena_id).each { |member| granter_names << member.name }
    return granter_names
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


  def member_cards
    if is_member?
      MemberCard.where(:member_id => id)
    else
      granters = MemberCardGranter.where(:granter_id => id).all
      MemberCard.where("id IN (#{granters.map(&:member_card_id).join(',')})")
    end
  end

  def member_card_left_times
    if (self.member_cards.nil? || self.member_cards.length == 0)
      return 0
    end
    left_times = 0
    for card in self.member_cards
      left_times += card.left_times.to_i
    end
    return left_times
  end

  def member_card_left_fees
    if (self.member_cards.nil? || self.member_cards.length == 0)
      return 0
    end
    left_fees = 0
    for card in self.member_cards
      left_fees += card.left_fee.to_f
    end
    return left_fees
  end

  def member_consume_amounts
    #consume_amounts = Order.where(:member_id => self.id).sum('amount')
    #consume_amounts.nil? ? 0 : consume_amounts
    self.orders.present? ? self.orders.inject(0){|s,o| s + o.amount} : 0
  end

  def latest_comer_date
    order = Order.where(:member_id => self.id).order("order_time").first
    order.nil? ? "" : DateUtil::timeshort(order.order_time)
  end

  def recharge_fees
    RechargeRecord.where(:member_id => self.id).sum('recharge_fee')
  end

  def recharge_times
    RechargeRecord.where(:member_id => self.id).sum('recharge_times')
  end

  def use_card_times
    #  order_ids = []
    #  Order.where(:member_id => self.id).each { |i|
    #    order_ids << i.id
    #  }
    #  ct = 0
    #  ct = Balance.where("order_id in (?) and (balance_way = ? or goods_balance_type = ?)", order_ids, Balance::Balance_Way_Use_Card, Balance::Balance_Way_Use_Card).size if order_ids.size > 0
    #  return ct
    #self.balances.balanced.where( ["(balance_way = ? or goods_balance_type = ?)",Balance::Balance_Way_Use_Card, Balance::Balance_Way_Use_Card]).inject(0){|s,b| s + b.count_amount}
    self.balances.balanced.count
  end

  def use_cash_amount
    book_record_amount = self.balances.balanced.where( ["(balance_way = ?)",Balance::Balance_Way_Use_Cash]).inject(0){|s,b| s + b.book_record_realy_amount}
    good_amount = self.balances.balanced.where( ["(goods_balance_type = ?)",Balance::Balance_Way_Use_Cash]).inject(0){|s,b| s + b.goods_realy_amount}
    return book_record_amount + good_amount
  end

  def use_card_amount
    book_record_amount = self.balances.balanced.where( ["(balance_way = ?)",Balance::Balance_Way_Use_Card]).inject(0){|s,b| s + b.book_record_realy_amount}
    good_amount = self.balances.balanced.where( ["(goods_balance_type = ?)",Balance::Balance_Way_Use_Card]).inject(0){|s,b| s + b.goods_realy_amount}
    return book_record_amount + good_amount
  end


end
