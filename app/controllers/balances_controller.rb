class BalancesController < ApplicationController
  layout 'main'
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

  def create
    @order    = Order.find(params[:order_id])
    if params[:user_name].blank? or params[:password].blank?
      pre_date_for_new_create
      @balance = Balance.find_by_order_id(@order.id) || Balance.new_from_order(@order)
      @balance.errors.add(:base,"结算人，密码不能为空")
      render :action => "new"
      return
    end
    user = User.find_by_login(params[:user_name])
    if user.blank? or !user.valid_password?(params[:password])
      pre_date_for_new_create
      @balance = Balance.find_by_order_id(@order.id) || Balance.new_from_order(@order)
      @balance.errors.add(:base,"结算人或者密码不正确")
      render :action => "new"
      return
    end

    @balance  = Balance.new(params[:balance])
    if @balance.to_change? && !user.can?("变更总价")
      pre_date_for_new_create
      @balance = Balance.find_by_order_id(@order.id) || Balance.new_from_order(@order)
      @balance.errors.add(:base,"用户无权限")
      render :action => "new"
      return
    end


    @balance.order_id = @order.id
    @balance.user_id = user.id
        
    @balance.book_reocrd_member_card_id = @order.member_card_id
    @balance.goods_member_card_id = @order.member_card_id

    @balance.merge_order(@order)
    if @balance.process && @balance.to_balance?
      pre_date_for_new_create
      redirect_to order_balance_path(@order,@balance,:popup => true) 
    elsif @balance.process && @balance.to_change?
      @balance.change_note_by(user) 
      pre_date_for_new_create
      render :action => "new"
    else
      pre_date_for_new_create
      render :action => "new"
    end
  end

  def update
    @order    = Order.find(params[:order_id])
    @balance  = Balance.find(params[:id])

    if params[:user_name].blank? or params[:password].blank?
      pre_date_for_new_create
      @balance = Balance.find_by_order_id(@order.id) || Balance.new_from_order(@order)
      @balance.errors.add(:base,"用户名或者密码不能为空")
      render :action =>  "new" 
      return
    end
    user = User.find_by_login(params[:user_name])
    if user.blank? or !user.valid_password?(params[:password])
      pre_date_for_new_create
      @balance = Balance.find_by_order_id(@order.id) || Balance.new_from_order(@order)
      @balance.errors.add(:base,"用户名或者密码不能为空")
      render :action =>  "new"
      return
    end

    @balance.attributes=params[:balance]
    if @balance.to_change? && !user.can?("变更总价")
      pre_date_for_new_create
      @balance.errors.add(:base,"用户无权限")
      render :action => "new"
      return
    end



    @balance.merge_order(@order)
    if @balance.process
      @balance.change_note_by(user) if @balance.operation == "change"
      pre_date_for_new_create
      if @balance.operation == "change"
        render :action => "new"
      else
        # redirect_to order_balance_path(@order,@balance) 
        redirect_to order_balance_path(@order,@balance,:popup => true) 
      end
    else
      pre_date_for_new_create
      render :action => "new"
    end
  end

  def show
    @order    = Order.find(params[:order_id])
    @balance  = Balance.find(params[:id])
    @good_items = @order.product_items
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

    order = Order.new(:order_time => Time.now,:user_id => current_user.id)
    if params[:member] == 'member'
      member_card = MemberCard.find_by_id(params[:member_card_id]) || MemberCard.find_by_card_serial_num(params[:member_card_id])
      member= Member.find(params[:member_id])
      order.parent_id = 0
      order.member_type = 1 
      order.member_id = member.id 
      order.member_card_id = member_card.id
      order.member_name = member.name
      order.save(false)
      cart.touch
      order.order_goods(cart.products)
      balance = Balance.new
      balance.operation = "balance"
      balance.order =order
      balance.balance_way = params[:balance_way]
      balance.member_type =  1#order.member_type
      balance.goods_balance_type = params[:balance_way]
      balance.goods_amount = cart.total_price
      balance.goods_realy_amount = cart.total_price
      balance.goods_member_card_id = member_card.id
      balance.member_id = member.id
      balance.user_id = current_user.id 
      balance.change_note = "折后价格" if cart.discount?
      if  balance.process
        cart.empty!
        redirect_to  new_good_buy_balances_path(:popup => true,:id => balance.id),:notice => "支付成功" and return

        #redirect_to  balance_path(balance,:order_id => balance.order_id),:notice => "支付成功" and return
        #redirect_to  print_balance_path(balance),:notice => "支付成功" and return
      else
        redirect_to  new_good_buy_balances_path,:notice => balance.errors.full_messages and return
      end
      # 会员购买
    else
      # 非会员
      order.parent_id = 0
      order.member_card_id = -1
      order.member_type = 0 
      order.member_name = params[:sanke_name]
      order.save(false)
      cart.touch
      order.order_goods(cart.products)
      balance = Balance.new
      balance.operation = "balance"
      balance.order = order
      balance.balance_way = params[:balance_way]
      balance.member_type =  0#order.member_type
      balance.goods_balance_type = params[:balance_way]
      balance.goods_amount = cart.total_price
      balance.goods_realy_amount = cart.total_price
      balance.user_id = current_user.id
      balance.status = 1
      balance.save(false)
      cart.empty!
      #redirect_to  new_good_buy_balances_path,:notice => "支付成功" and return
      redirect_to  new_good_buy_balances_path(:popup => true,:id => balance.id),:notice => "支付成功" and return
      #redirect_to  print_balance_path(balance),:notice => "支付成功" and return
      #redirect_to  balance_path(balance,:order_id => balance.order_id),:notice => "支付成功" and return
    end
    redirect_to  new_good_buy_balances_path
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
