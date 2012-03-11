# -*- encoding : utf-8 -*-
class GoodsController < ApplicationController
  before_filter :load_good, :only => [:show, :edit, :update,:destroy, :store_manage_update]

  def autocomplete_name
    render :json => Good.where(["pinyin_abbr like ? or name like ? ","%#{params[:term]}%","%#{params[:term]}%"]).all.collect(&:name).to_json
  end


  def autocomplete_good
    goods = []
    @goods = Good.where(["pinyin_abbr like ? or name like ? ","%#{@name}%","%#{@name}%"]) unless params[:name].blank?
    @goods.each do |g| goods << {:label => g.name,:value => g.name,:id => g.id,:price => g.price} end
    render :inline => goods.to_json
  end


  def index
    @p = params[:p]
    @good_type = params[:good_type]
    @name = params[:name]
    @category = Category.find_by_id(@good_type)
    @goods = @category.nil? ? Good.order("id desc") :  @category.all_goods.order("id desc")
    @goods = @goods.where(["pinyin_abbr like ? or name like ? ","%#{@name}%","%#{@name}%"]) unless params[:name].blank?
    @goods = @goods.paginate(default_paginate_options)
  end


  def show
    @good = Good.find(params[:id])
  end

  def new
    @good = Good.new
  end

  def edit
    @good = Good.find(params[:id])
  end

  def create
    @good = Good.new(params[:good])
    @good.count_total_now = @good.count_back_stock
    @good.count_front_stock = 0
    if @good.save
      redirect_to(@good, :notice => '商品信息添加成功！') 
    else
      render :action => "new" 
    end
  end

  def update
    @good.count_total_now = @good.count_back_stock + @good.count_front_stock

    if @good.update_attributes(params[:good])
      redirect_to(@good, :notice => '商品信息修改成功！') 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @good.destroy

    redirect_to goods_url
  end

  def store_manage_index
    @p = params[:p]
    @good = Good.find params[:id]
    render :layout => false
  end

  def store_manage_update
    @p = params[:p]
    count_back_stock_out = params[:good][:count_back_stock_out].to_i
    count_back_stock_in  = params[:good][:count_back_stock_in].to_i
    count_front_stock_in = params[:good][:count_front_stock_in].to_i
    @good.count_back_stock  += (count_back_stock_in - count_back_stock_out - count_front_stock_in )
    @good.count_front_stock += count_front_stock_in
    @good.count_total_now   = @good.count_back_stock + @good.count_front_stock
    msg = @good.save ? 'yes' : 'no'
    render :text => msg
  end

  def goods
    @order = Order.find(params[:order_id])
    if params[:name]
      name = "%#{params[:name]}%"
      @goods = Good.enabled.where(["name like ? or name_pinyin like ? or pinyin_abbr like ?",
                                      name, name, name ]).order('count_back_stock_out desc').limit(20)
    else
      @goods = Good.enabled.order('count_back_stock_out desc').limit(20)
    end
    render :layout => "small_main"
  end

  def to_buy
    @goods = Good.enabled.order('sale_count desc').limit(20)
    render :action => 'goods'
  end

  def add_to_cart
    goods = []
    (params[:goods]||[]).map{|hash_good|
      next if  hash_good[:count].to_i <= 0
      good = Good.find(hash_good[:id])
      good.order_count = hash_good[:count].to_i
      goods << good
    }
    order = Order.find(params[:order_id])
    unless (good_items = order.order_goods(goods)).blank?
      render :partial => "/orders/order_item", :locals => {:good_items => good_items,:order => order}
    else
      render :text => "<span class='error' style='color:red'>#{order.errors.full_messages.join('<br/>')}</span>"
    end
  end

  def load_good
    @good = Good.find params[:id]
    
  end

end
