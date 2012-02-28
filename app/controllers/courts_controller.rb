# -*- encoding : utf-8 -*-
class CourtsController < ApplicationController
  before_filter :generate_period_prices, :only => [:show, :new, :edit, :create, :update]

  def index
    @courts = Court.paginate(default_paginate_options)
  end

  def show
    @court = Court.find(params[:id])
  end

  def new
    @court = Court.new
  end

  def edit
    @court = Court.find(params[:id])
  end

  def create
    @court = Court.new(params[:court])

    for period_price in PeriodPrice.search_order
      @court.court_period_prices << CourtPeriodPrice.new(:period_price_id => period_price.id,
                                                         :court_price =>  period_price.price)
                                                         
    end

    if @court.save
      redirect_to(@court, :notice => '场地信息添加成功！') 
    else
      render :action => "new" 
    end
  end

  def update
    @court = Court.find(params[:id])
    format_court_period_price @court
    if @court.update_attributes(params[:court])
      redirect_to(@court, :notice => '场地信息修改成功！') 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @court = Court.find(params[:id])
    @court.destroy
    redirect_to(courts_url) 
  end

  def switch_state 
    @court = Court.find(params[:id])
    @court.switch_state!
    redirect_to courts_url
  end



  def court_status_search
    @court_book_records = CourtBookRecord.paginate(default_paginate_options.merge!(:order => "id asc"))
  end

  def coach_status_search
    @coach_book_records = CoachBookRecord.paginate(default_paginate_options.merge!(:order => "id asc"))
  end

  def court_record_detail
    @court = Court.where(:name => params[:court_name]).first
    @search_hour = params[:search_hour] ||= Date.today
    @record_date = params[:record_date]
    @order_items = OrderItem.where(:order_date => @record_date).where("start_hour <= ? and end_hour >= ? ", @search_hour, @search_hour).where(:item_id => @court.id).order("start_hour")
    @order_infos = []
    for order_item in @order_items
      item_info = [
        order_item.start_hour,
        order_item.end_hour,
        order_item.order.member_name
      ]
      @order_infos << item_info
    end
    render :layout => false
  end

  protected

  def generate_period_prices
    @period_prices = PeriodPrice.search_order
  end

  private

  def format_court_period_price(court)
    for period_price in PeriodPrice.search_order
      court.court_period_prices << CourtPeriodPrice.new(:period_price_id => period_price.id,
                                                        :court_price =>  period_price.price)
                                                        
    end
  end
end
