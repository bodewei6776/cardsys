class CourtsController < ApplicationController
  before_filter :generate_period_prices, :only => [:show, :new, :edit, :create, :update]

  def index
    @courts = Court.all.paginate(default_paginate_options)
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
                                                         :court_price =>  period_price.price,
                                                         :catena_id =>  session[:catena_id])
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

  def change_status
    @court = Court.find(params[:id])
    @court.update_attribute("status", params[:status])
    redirect_to courts_url
  end


  def coach_status_search
    coach = Coach.where(:name => params[:name]).first  unless params[:name].blank?
    start_date = params[:start_date].blank? ? Date.today : Date.parse(params[:start_date])
    end_date = params[:end_date].blank? ? Date.today : Date.parse(params[:end_date])
    member = Member.where(:name => params[:member_name]).first unless params[:member_name].blank?
    start_hour,end_hour = params[:start_hour],params[:end_hour]
    @caoches = Coach.all
    @order_items = OrderItem.coaches.select('order_items.*')
    @order_items = @order_items.where(:item_id => coach.id) if coach
    orde_inner_join = "INNER JOIN orders ON orders.id=order_items.order_id"
    @order_items = @order_items.joins(orde_inner_join)

    br_inner_join = " INNER JOIN book_records ON orders.book_record_id=book_records.id "
    @order_items = @order_items.joins(br_inner_join)

    @order_items = @order_items.where(["order_items.start_hour >= ?", start_hour]) unless start_hour.blank?
    @order_items = @order_items.where(["order_items.end_hour <= ?", end_hour]) unless end_hour.blank?
    @order_items = @order_items.order("item_id, start_hour")
    @order_items = @order_items.paginate(:page => params[:page]||1,:per_page => 15)

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
                                                        :court_price =>  period_price.price,
                                                        :catena_id =>  session[:catena_id])
    end
  end
end
