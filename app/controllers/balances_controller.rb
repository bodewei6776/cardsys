# -*- encoding : utf-8 -*-
class BalancesController < ApplicationController

  def index
    @order = Order.find(params[:order_id])
    @balances = @order.balances
    @balance = Balance.new(:order_id => params[:order_id])
    @balance.order_items = @order.order_items
    render :layout => "small_main"
  end

  def balanced
    @balances = Balance.balanced.order('created_at desc').paginate(default_paginate_options_without_created_at)
  end

  def unbalanced
    @unbalanced_orders = Order.paginate(default_paginate_options.merge(:conditions => ["state = ? ", "activated"]))
  end

  def create
    @order = Order.find(params[:balance][:order_id])
    @balances = @order.balances
    @balance = @order.balances.new(params[:balance]) 
    if  @balance.save
      log_action(@order.court_book_record, "balance", @balance.user || current_user, "")
      flash[:notice] = "结算成功"
      redirect_to :action => "index", :order_id => @order.id
    else
      flash[:notice] =  @balance.errors.messages.values.collect(&:first).join(", ")
      redirect_to :action => "index", :order_id => @order.id
    end
  end

  def print 
    @balance  = Balance.find(params[:id])
    @order = @balance.order
    render :layout => false
  end

  def new_good_buy
  end

  def clear_goods
    session[:cart] = Cart.new
    redirect_to new_good_buy_balances_path
  end

  def add_good
    session[:cart]  ||= Cart.new
    params[:goods].each do |g|
      session[:cart].add(g[:id],g[:count].to_i)
    end
    render :partial => "cart_goods_list"
  end

  def destroy_good
    session[:cart].remove(Integer(params[:id]))
    redirect_to new_good_buy_balances_path
  end

  def change_li_real_total_price
    session[:cart].change_li_real_total_price(params[:product_id],params[:real_total_price],params[:discount])
    redirect_to new_good_buy_balances_path
  end

  def member_by_member_card_serial_num
    @card = MembersCard.find_by_card_serial_num(params[:serial_num])
    @member = @card.member
    render :json => {:name => @member.name,:id => @member.id}
  end

  def create_good_buy
    if cart.blank?
      redirect_to new_good_buy_balances_path ,:notice => "购物车是空的" and return
    end
    is_member = params[:member] == 'member'

    @order = Order.new(:user_id => current_user.id)
    @order.is_member = is_member 
    if is_member
      member_card = MembersCard.find(params[:member_card_id]) 
      member= Member.find(params[:member_id])
      @order.member_id = member.id
      @order.members_card_id = member_card.id 
    else
      @order.non_member =  NonMember.new(:name => params[:sanke_name])
    end
    cart.line_items.each do |li|
      @order.order_items.build({:item => li.product,
                               :quantity => li.quantity,
                               :total_money_price => li.sub_total_price,
                               :unit_money_price => li.product.price, 
                               :price_after_discount => li.real_total_price,
                               :discount => li.discount})
    end


    if @order.save(:validate => false)
      @balance = @order.balances.build(params[:balance])
      @balance.price = @order.order_items.sum(&:total_money_price)
      @balance.final_price = @order.order_items.sum(&:price_after_discount)
      @order.order_items.sum(&:price_after_discount)
      @balance.price
      @balance.final_price
      @balance.save && @order.update_column(:state, "balanced")
      cart.empty!
      flash[:notice] = "商品购买成功"
    else
      flash[:notice] = "支付失败" + @balance.errors.full_messages.join(", ")
    end
    redirect_to new_good_buy_balances_path
  end

  def destroy
    @balance = Balance.find(params[:id])
    @order = @balance.order
    log_action(@order.court_book_record, "destroy", current_user)
    if @balance.order.return_money && @balance.order.destroy && @balance.destroy
      flash[:notice] = "删除成功"
    else
      flash[:notice] = "删除失败"
    end
    redirect_to balanced_balances_path
  end


  def show
    @balance = Balance.find params[:id]
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
