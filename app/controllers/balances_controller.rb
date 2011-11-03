class BalancesController < ApplicationController

  def index
    @book_records = BookRecord.playing.order('created_at desc').paginate(default_paginate_options_without_created_at)
  end

  def balanced
    @book_records = BookRecord.balanced.order('created_at desc').paginate(default_paginate_options_without_created_at)
  end

  def edit 
    @balance = Balance.find(params[:id])
    @order = @balance.order
    @book_record = @order.book_record
    pre_date_for_new_create
  end

  def update
    @order    = Order.find(params[:order_id])
    @balance  = Balance.find(params[:id])

    unless login_and_password_valid? 
      pre_date_for_new_create
      @balance = Balance.find_by_order_id(@order.id) || Balance.new_from_order(@order)
      @balance.errors.add(:base,"用户名或者密码不正确")
      render :action =>  "edit" 
      return
    end

    if @balance.order.member_card.card.is_counter_card?
      if params[:balance][:balance_way] == "7" and @balance.balance_items.count > 1
        pre_date_for_new_create
        @balance.errors.add(:base, "计次卡只能结算场地")
        render :action => "edit" and return
      end
    end

    @balance.update_attributes(params[:balance])

    if @balance.do_balance!
      log_action("通过" + @balance.balance_way_desc + "支付了" + @balance.balance_amount_desc, :balance)
      @balance.update_attribute(:user_id,  current_user.id)
      pre_date_for_new_create
      redirect_to order_balance_path(@order,@balance,:popup => true) 
    else
      pre_date_for_new_create
      render :action => "edit"
    end
  end

  def show
    @order    = Order.find(params[:order_id])
    @balance  = Balance.find(params[:id])
    @good_items = @order.order_items
    pre_date_for_new_create
    render :layout => params[:layout].blank?
  end

  def print 
    @balance  = Balance.find(params[:id])
    render :layout => false
  end

  def new_good_buy
    @order = Order.new
    @order.member_type = Const::YES
  end

  def clear_goods
    session[:cart] = Cart.new
    redirect_to new_good_buy_balances_path
  end

  def add_good
    session[:cart]  ||= Cart.new
    params[:goods].each do |g|
      #session[:cart].destock(g[:id],g[:count].to_i)
      session[:cart].add(g[:id],g[:count].to_i)
    end
    #redirect_to new_good_buy_balances_path
    render :partial => "cart_goods_list"
  end

  def destroy_good
    #session[:cart].restock(params[:id])
    session[:cart].remove(params[:id])
    redirect_to new_good_buy_balances_path
  end

  def change_li_real_total_price
    session[:cart].change_li_real_total_price(params[:product_id],params[:real_total_price],params[:discount])
    render :partial => "cart_goods_list"
  end

  def member_by_member_card_serial_num
    @card = MemberCard.find_by_card_serial_num(params[:serial_num])
    @member = @card.member
    render :json => {:name => @member.name,:id => @member.id}
  end

  def create_good_buy
    if cart.blank?
      redirect_to new_good_buy_balances_path ,:notice => "购物车还是空的啊" and return
    end

    is_member = params[:member] == 'member'

    @order = Order.new(:order_time => Time.now,:user_id => current_user.id)
    member_card = MemberCard.find_by_id(params[:member_card_id]) || MemberCard.find_by_card_serial_num(params[:member_card_id])
    member= Member.find_by_id(params[:member_id])
    @order.parent_id = 0
    @order.member_type = is_member ? 1 : 0 
    @order.member_name = is_member ? member.name : params[:sanke_name]
    @order.member_id = is_member ? member.id : -1
    @order.member_card_id = is_member ? member_card.id : -1
    @order.book_record_id = -1
    @order.save(false)
    cart.touch
    @order.order_goods(cart.products)
    balance = @order.balance
    balance.operation = "balance"
    balance.balance_way = params[:balance_way]
    balance.change_note = "折后价格" if cart.discount?
    balance.do_balance!
    cart.empty!
    redirect_to new_good_buy_balances_path(:popup => true, :id => balance.id), :notice => "支付成功"
  rescue Exception => e
    redirect_to new_good_buy_balances_path, :notice => e.message
  end

  def destroy
    @balance = Balance.find(params[:id])
    if @balance.order.destroy && @balance.destroy
      flash[:notice] = "删除成功"
    else
      flash[:notice] = "删除失败"
    end
    redirect_to balanced_balances_path
  end



  protected
  def pre_date_for_new_create
    @book_record  = @order.book_record
    if @order.is_member?
      @member         = @order.member
      @current_card   = @order.member_card
      @member_cards = @member.member_cards
    end
    @good_items = @order.product_items
  end

end
