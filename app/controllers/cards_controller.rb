class CardsController < ApplicationController
  before_filter :load_card, :only => [:show, :edit, :update, :destroy]

  def index
    @cards = Card.paginate(default_paginate_options)
  end

  def show
    @period_prices = PeriodPrice.search_order
    @goods = Good.where(:status => 1)
  end

  def new
    @card = Card.new
    @period_prices = PeriodPrice.search_order
    @goods = Good.where(:status => 1)
  end

  def edit
    @period_prices = PeriodPrice.search_order
    @goods = Good.where(:status => 1)
  end

  def create
    @card = Card.new(params[:card])
    @card.catena_id = session[:catena_id]
    @card.status = CommonResource::CARD_ON

    #设置卡的时段价格
    @period_prices = PeriodPrice.search_order
    format_card_period_price @card 

    respond_to do |format|
      if @card.save
        format.html { redirect_to(@card, :notice => '卡信息创建成功！') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @period_prices = PeriodPrice.all
    @goods = Good.all

    CardPeriodPrice.delete_all("card_id = #{params[:id]}")
    format_card_period_price @card

    respond_to do |format|
      if @card.update_attributes(params[:card])
        format.html { redirect_to(@card, :notice => '卡信息修改成功！') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    if @card.member_cards.first
      flash[:notice] = "此类型的卡已经有绑定，不能删除！"
    else
      @card.destroy
      flash[:notice] = "删除成功！"
    end
    redirect_to(cards_url) 
  end

  def change_status
    @card = Card.find(params[:id])
    @card.update_attribute("status", params[:status])
    redirect_to(cards_url) 
  end

  private
  def format_card_period_price(card)
    for period_price in PeriodPrice.search_order
      #被选中可用的时段
      if params["time_available_#{period_price.id}"]
        price = params["time_discount_#{period_price.id}"]
        if price.nil? || price.blank?
          price = 0
        end
        card.card_period_prices << CardPeriodPrice.new(:period_price_id => period_price.id,
                                                       :card_price =>  price,
                                                       :catena_id =>  session[:catena_id])
      end
    end
  end

  def load_card 
    @card = Card.find(params[:id])    
  end
end
