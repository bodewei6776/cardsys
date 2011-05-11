class CourtsController < ApplicationController

  layout 'main'

  before_filter :generate_period_prices, :only => [:show, :new, :edit, :create, :update]

  # GET /courts
  # GET /courts.xml
  def index
    @courts = Court.all.paginate(default_paginate_options)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courts }
    end
  end

  # GET /courts/1
  # GET /courts/1.xml
  def show
    @court = Court.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @court }
    end
  end

  # GET /courts/new
  # GET /courts/new.xml
  def new
    @court = Court.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @court }
    end
  end

  # GET /courts/1/edit
  def edit
    @court = Court.find(params[:id])
  end

  # POST /courts
  # POST /courts.xml
  def create
    @court = Court.new(params[:court])
    #    format_court_period_price @court

    for period_price in PeriodPrice.search_order
      #设置所有时间段可用
      @court.court_period_prices << CourtPeriodPrice.new(:period_price_id => period_price.id,
        :court_price =>  period_price.price,
        :catena_id =>  session[:catena_id])
    end

    respond_to do |format|
      if @court.save
        format.html { redirect_to(@court, :notice => '场地信息添加成功！') }
        format.xml  { render :xml => @court, :status => :created, :location => @court }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @court.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courts/1
  # PUT /courts/1.xml
  def update
    @court = Court.find(params[:id])

    CourtPeriodPrice.delete_all("court_id = #{params[:id]}")
    format_court_period_price @court

    respond_to do |format|
      if @court.update_attributes(params[:court])
        format.html { redirect_to(@court, :notice => '场地信息修改成功！') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @court.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /courts/1
  # DELETE /courts/1.xml
  def destroy
    @court = Court.find(params[:id])
    @court.destroy
    respond_to do |format|
      format.html { redirect_to(courts_url) }
      format.xml  { head :ok }
    end
  end

  def change_status
    @court = Court.find(params[:id])
    @court.update_attribute("status", params[:status])
    respond_to do |format|
      format.html { redirect_to(courts_url) }
      format.xml  { head :ok }
    end
  end

  def court_status_search
    court = Court.where(:name => params[:name]).first unless params[:name].blank?
    date = params[:search_date].blank? ? Date.today : Date.parse(params[:search_date])
    member = Member.where(:name => params[:member_name]).first unless params[:member_name].blank?
    start_hour,end_hour = params[:start_hour],params[:end_hour]
    @order_items = OrderItem.book_records.order("item_id, start_hour").select('order_items.*')
    @order_items = @order_items.joins("INNER JOIN orders ON orders.id=order_items.order_id AND orders.member_id=#{member.id}") if member
    if court || date
      book_record_inner_join = "INNER JOIN book_records ON order_items.item_id=book_records.id"
      book_record_inner_join << " AND book_records.court_id=#{court.id}" if court
      book_record_inner_join << " AND book_records.record_date = '#{date.to_s(:db)}'" if date
      @order_items = @order_items.joins(book_record_inner_join)
    end
    @order_items = @order_items.where(["order_items.start_hour >= ?", start_hour]) unless start_hour.blank?
    @order_items = @order_items.where(["order_items.end_hour <= ?", end_hour]) unless end_hour.blank?
    @order_items = @order_items.paginate(:page => params[:page]||1,:per_page => 15)
    respond_to do |format|
      format.html
    end
    
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
     orde_inner_join << " AND orders.member_id=#{member.id}"  if member
     @order_items = @order_items.joins(orde_inner_join)

     br_inner_join = " INNER JOIN book_records ON orders.book_record_id=book_records.id "
     br_inner_join << " AND book_records.record_date >= '#{start_date.to_s(:db)}' AND book_records.record_date<= '#{end_date.to_s(:db)}'"
     @order_items = @order_items.joins(br_inner_join)
     
     @order_items = @order_items.where(["order_items.start_hour >= ?", start_hour]) unless start_hour.blank?
     @order_items = @order_items.where(["order_items.end_hour <= ?", end_hour]) unless end_hour.blank?
     @order_items = @order_items.order("item_id, start_hour")
     @order_items = @order_items.paginate(:page => params[:page]||1,:per_page => 15)
     respond_to do |format|
       format.html
     end
     
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
      #被选中可用的时段
      if params["time_available_#{period_price.id}"]
        court.court_period_prices << CourtPeriodPrice.new(:period_price_id => period_price.id,
          :court_price =>  period_price.price,
          :catena_id =>  session[:catena_id])
      end
    end
  end
end
