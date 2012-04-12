# -*- encoding : utf-8 -*-
class OrdersController < ApplicationController

  def index
    @courts       = Court.enabled
    @date = params[:date].blank? ? Date.today : Date.parse(params[:date])
    @daily_periods   = PeriodPrice.all_periods_in_time_span(@date)
    @predate      = @date.yesterday.strftime("%Y-%m-%d")
    @nextdate     = @date.tomorrow.strftime("%Y-%m-%d")    
  end

  def new
    @order = Order.new
    @order.is_member = true
    @order.court_book_record = CourtBookRecord.new(params[:court_book_record])
    @order.court_book_record.resource_type = 'Court'
    @order.member = Member.new
    @order.order_date = @order.court_book_record.alloc_date
    @order.non_member = NonMember.new(:is_member => "1", :earnest => 0)
    @order.telephone = @order.member.telephone
    render :layout => "small_main"
  end

  def edit
    @order = Order.find(params[:id])
    @order.build_non_member(:is_member => "1") if @order.is_member
    render :layout => "small_main"
  end

  def update
    @order = Order.find(params[:id])
    case params[:commit]
    when "代卖"
      if @order.split params[:order]
        render :action => "create"
      else
        render :action => "edit", :layout => "small_main"
      end
    when "变更"
      if @order.update_attributes(params[:order])
        flash[:notice] = "场地修改成功"
        render :action => "create", :layout => "small_main"
      else
        render :action => "edit", :layout => "small_main"
      end
    when "开场", "申请代卖", "取消代卖", "取消预订", "连续取消", "连续变更"
      be_action = Order::OPMAP.invert[params[:commit]]
      if @order.update_attributes(params[:order].slice(:login, :password)) && @order.send(be_action)
        flash[:notice] = "场地#{params[:commit]}成功"
        render :action => "create", :layout => "small_main"
      else
        render :action => "edit", :layout => "small_main"
      end
    end
  end

  def create
    @order = Order.new(params[:order])
    @order.state = "booked"
    if @order.save
      flash[:notice] = "场地预订成功"
      render :layout => "small_main"
    else
      @order.build_non_member(:is_member => @order.is_member, :earnest => 0)
      render :action => "new", :layout => "small_main"
    end
  end

  def change_state
    @order = Order.find(params[:id])
    begin
      @order.send("#{params[:be_action]}!") 
      render :action => "create"
    rescue
      flash[:notice] = "不能进行此操作"
      render :action => "edit", :layout => "small_main"
    end
  end

  def sell
    @order = Order.find params[:id]
    if @order.split
      redirect_to edit_order_path(@order)
    else
      render :action => "edit"
    end
  end

end
