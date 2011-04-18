class CardsController < ApplicationController
  layout 'main'
  # GET /card_templates
  # GET /card_templates.xml
  def index
    @cards = Card.paginate(default_paginate_options)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cards }
    end
  end

  # GET /card_templates/1
  # GET /card_templates/1.xml
  def show
    @card = Card.find(params[:id])
    @period_prices = PeriodPrice.search_order
    @goods = Good.where(:status => 1)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @card }
    end
  end

  # GET /card_templates/new
  # GET /card_templates/new.xml
  def new
    @card = Card.new
    @period_prices = PeriodPrice.search_order
    @goods = Good.where(:status => 1)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @card }
    end
  end

  # GET /card_templates/1/edit
  def edit
    @card = Card.find(params[:id])
    @period_prices = PeriodPrice.search_order
    @goods = Good.where(:status => 1)
  end

  # POST /card_templates
  # POST /card_templates.xml
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
        format.xml  { render :xml => @card, :status => :created, :location => @card }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @card.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /card_templates/1
  # PUT /card_templates/1.xml
  def update
    @card = Card.find(params[:id])
    @period_prices = PeriodPrice.all
    @goods = Good.all

    CardPeriodPrice.delete_all("card_id = #{params[:id]}")
    format_card_period_price @card

    respond_to do |format|
      if @card.update_attributes(params[:card])
        format.html { redirect_to(@card, :notice => '卡信息修改成功！') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @card.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /card_templates/1
  # DELETE /card_templates/1.xml
  def destroy
    @card = Card.find(params[:id])    
    if @card.member_cards.first
      flash[:notice] = "此类型的卡已经有绑定，不能删除！"
    else
      @card.destroy
      flash[:notice] = "删除成功！"
    end
    respond_to do |format|
      format.html { redirect_to(cards_url) }
      format.xml  { head :ok }
    end
  end

  def change_status
    @card = Card.find(params[:id])
    @card.update_attribute("status", params[:status])
    respond_to do |format|
      format.html { redirect_to(cards_url) }
      format.xml  { head :ok }
    end
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
end
