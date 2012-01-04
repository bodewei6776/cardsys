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

  def switch_state
    @card = Card.find(params[:id])
    ap @card.switch_state!
    ap @card.state
    redirect_to(cards_url) 
  end

  def default_card_serial_num
    card = Card.find(params[:id])
    cardNo = card.card_prefix + member_card_num4(card)
    render :json => { :card_serial_num => cardNo }
  end

  def member_card_num4(card)
    last_member_card = card.members_cards.last
    ap  last_member_card.card_serial_num[card.card_prefix.length..-1]
    last_member_card.nil? ? "00001" : last_member_card.card_serial_num[card.card_prefix.length..-1].succ
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
                                                       :card_price =>  price)
      end
    end
  end

  def load_card 
    @card = Card.find(params[:id])    
  end
end
