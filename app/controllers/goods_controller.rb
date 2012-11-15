# -*- encoding : utf-8 -*-
class GoodsController < ApplicationController
  before_filter :load_good, :only => [:show, :edit, :update,:destroy, :store_manage_update]
  before_filter :search_goods, :only => [:index, :back, :front]

  def autocomplete_barcode
    render :json => Good.where(["barcode = ? ","#{params[:term].strip}"]).all.collect(&:name).to_json
  end


  def autocomplete_name
    render :json => Good.where(["pinyin_abbr like ? or name like ? or barcode like ?","%#{params[:term]}%","%#{params[:term]}%", "%#{params[:term]}%"]).all.collect(&:name).to_json
  end

  def by_category
   render :json => Good.all(:conditions => {:good_type =>  params[:category]}).to_json
  end


  def autocomplete_good
    goods = []
    @goods = Good.where(["pinyin_abbr like ? or name like ? ","%#{@name}%","%#{@name}%"]) unless params[:name].blank?
    @goods.each do |g| goods << {:label => g.name,:value => g.name,:id => g.id,:price => g.price} end
    render :inline => goods.to_json
  end


  def index
  end

  def back
  end

  def front
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
      redirect_to(goods_path, :notice => '商品信息添加成功！') 
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
    redirect_to back_goods_url
  end


  def back_store_manage
    @good = Good.find params[:id]
    render :layout => false
  end

  def front_store_manage
    @good = Good.find params[:id]
    @good.count_front_stock_in = 0
    render :layout => false
  end

  def back_store_update
    @good = Good.find params[:id]
    count_back_stock_in = params[:good][:count_back_stock_in].to_i
    count_back_stock_out = params[:good][:count_back_stock_out].to_i
    @good.count_back_stock  += count_back_stock_in 
    @good.count_back_stock  -= count_back_stock_out
    @good.count_total_now += count_back_stock_in 
    @good.count_total_now -= count_back_stock_out
    @good.name = params[:good][:name]
    @good.barcode = params[:good][:barcode]
    unless @good.save
      flash[:notice] = "保存失败， 查看是否扫描码重复"
    end
    redirect_to back_goods_path
  end

  def front_store_update
    @good = Good.find params[:id]
    count_front_stock_in = params[:good][:count_front_stock_in].to_i
    @good.count_back_stock  -= count_front_stock_in
    @good.count_front_stock += count_front_stock_in
    @good.save
    redirect_to front_goods_path
  end

  def goods
    @order = Order.find(params[:order_id])
    @goods = Good.enabled
    name = params[:name] || params[:barcode] || ""
    @goods = @goods.where("name like '%#{name}%' or name_pinyin like '%#{name}%' or pinyin_abbr like '%#{name}%'" )
    @goods = @goods.where({:good_type => params[:good_type]}) if params[:good_type] and params[:good_type] != "0"
    @goods = @goods.limit(20)
    render :layout => "small_main"
  end


  def to_buy
    @goods = Good.enabled.order('sale_count desc').limit(20)
    render :action => 'goods'
  end

  def add_to_cart
    @good = Good.find_by_id(params[:id]) || Good.find_by_name(params[:name] || params[:barcode]) || Good.find_by_id(params[:good_id]) 
    cart.add(@good.id, Integer(params[:quantity])) if @good
    redirect_to new_good_buy_balances_path
  end

  def load_good
    @good = Good.find params[:id]

  end


  def switch_state
    @good = Good.find(params[:id])
    @good.switch_state!
    @good.state
    redirect_to(back_goods_url) 
  end

  def price
    if params[:name] =~ /^\d+$/
      @good = Good.find_by_barcode(params[:name])
    else
      @good = Good.find_by_name(params[:name])
    end
    render :json => {:id => @good.id, :price => @good.price }
  end

  def search_goods
    @category = Category.find_by_id(params[:good_type])
    @goods = @category.nil? ? Good.order("id DESC") :  @category.all_goods.order("id DESC")
    @goods = @goods.where(["pinyin_abbr LIKE ?", params[:name]]) if params[:name].present?
    @goods = @goods.where(["name LIKE ?", params[:name]]) if params[:name].present?
    @goods = @goods.where(["barcode = ? or name LIKE ?", params[:barcode], params[:barcode]]) if params[:barcode].present?
    @goods = @goods.paginate(default_paginate_options)
  end

end
