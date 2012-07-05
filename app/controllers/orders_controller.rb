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
    @order.end_date = @order.order_date 
    @order.non_member = NonMember.new(:is_member => "1", :earnest => 0)
    @order.telephone = @order.member.telephone
    render :layout => "small_main"
  end

  def edit
    @order = Order.find(params[:id])
    @order.activate! if @order.ought_to_activate?
    @order.build_non_member(:is_member => "1") if @order.is_member
    render :layout => "small_main"
  end

  def update
    @order = Order.find(params[:id])
    @original_member_name = @order.member_name
    case params[:commit]
    when "代卖"
      if  params[:order][:court_book_record_attributes][:resource_id].to_i != @order.court_book_record.resource_id
        flash[:notice] = "代卖不能换场地"
        render :action => "edit", :layout => "small_main"
        return
      end
      if @order = @order.split(params[:order])
        log_action(@order.court_book_record, "sell", @order.user || current_user, 
                   "#{@order.start_hour}:00-#{@order.end_hour}:00 " + " #{ '原预订人: ' + @original_member_name if @original_member_name != @order.member_name}"
                  )
        render :action => "create"
      else
        render :action => "edit", :layout => "small_main"
      end
    when "变更"
      @order.validate_in_condition_needed = true
      if @order.update_attributes(params[:order])
        log_action(@order.court_book_record, "change", @order.user || current_user, "#{@order.start_hour}:00-#{@order.end_hour}:00"  +
              " #{ '原预订人: ' + @original_member_name if @original_member_name != @order.member_name}"
                  )
        flash[:notice] = "场地修改成功"
        render :action => "create", :layout => "small_main"
      else
        render :action => "edit", :layout => "small_main"
      end
    when "连续变更"
      if @order.all_update_attributes(params[:order])
        log_action(@order.court_book_record, "all_change", @order.user || current_user, "#{@order.start_hour}:00-#{@order.end_hour}:00" + " #{ '原预订人: ' + @original_member_name if @original_member_name != @order.member_name}"
                  )
        flash[:notice] = "场地连续变更成功"
        render :action => "create", :layout => "small_main"
      else
        render :action => "edit", :layout => "small_main"
      end
    when "开场", "申请代卖", "取消代卖", "取消预订", "连续取消"
      be_action = Order::OPMAP.invert[params[:commit]]
      log_action(@order.court_book_record, be_action, @order.user || current_user, "#{@order.start_hour}:00-#{@order.end_hour}:00")
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
    @order.possible_batch_order = true
    if @order.save
      log_action(@order.court_book_record, "book", @order.user || current_user, "#{@order.start_hour}:00-#{@order.end_hour}:00")
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
