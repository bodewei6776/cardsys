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
    @order.non_member = NonMember.new(:is_member => "1")
    @order.telephone = @order.member.telephone
    render :layout => "small_main"
  end

  def edit
    @order = Order.find(params[:id])
    render :layout => "small_main"
  end

  def create
    @order = Order.new(params[:order])
    if @order.save
      flash[:notice] = "场地预订成功"
    else
      @order.non_member ||= NonMember.new(:is_member => @order.is_member)
      render :action => "new", :layout => "small_main"
    end
  end

  def change_state
    @order = Order.find(params[:id])
    begin
      @order.send("#{params[:be_action]}!") 
    rescue
      flash[:notice] = "不能进行此操作"
    end
  end
end
