class BalancesController < ApplicationController
  layout 'main'
  def index
    @book_records = BookRecord.playing.order('created_at desc,start_hour desc').paginate(default_paginate_options_without_created_at)
  end

  def balanced
    @book_records = BookRecord.balanced.order('created_at desc').paginate(default_paginate_options_without_created_at)
  end

  def new
    @order        = Order.find(params[:order_id])
    if @order.has_bean_balanced?
      balance = Balance.find_by_order_id(@order.id)
      redirect_to order_balance_path(@order,balance) and return
    end
    pre_date_for_new_create
    @balance = Balance.find_by_order_id(@order.id) || Balance.new_from_order(@order)
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
    @balance.order_id = @order.id
    @balance.user_id = user.id
    @balance.merge_order(@order)
    if @balance.process && @balance.to_balance?
      pre_date_for_new_create
      redirect_to order_balance_path(@order,@balance) 
    else
      pre_date_for_new_create
      render :action => "new"
    end
  end

  def update
    @order    = Order.find(params[:order_id])
    @balance  = Balance.find(params[:id])
    @balance.attributes=params[:balance]
    @balance.merge_order(@order)
    if @balance.process
      pre_date_for_new_create
      #render :action => "show"
      redirect_to order_balance_path(@order,@balance) 
    else
      pre_date_for_new_create
      render :action => "new"
    end
  end

  def show
    @order    = Order.find(params[:order_id])
    @balance  = Balance.find(params[:id])
    pre_date_for_new_create
    render :layout => params[:layout].blank?
  end

  def print 
    @balance  = Balance.find(params[:id])
    render :layout => false
  end

  def new_good_buy
    @order = Order.new
  end

  def create_good_buy
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
