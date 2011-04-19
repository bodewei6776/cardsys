class AdvancedOrdersController < ApplicationController

  layout  'main'
  
  def new
    @order    = AdvancedOrder.new 
    @coaches  = Coach.all
    @courts   = Court.all
    @book_record = BookRecord.new
  end
  
  def show
    pre_data_for_show_edit
  end
  
  def edit
    pre_data_for_show_edit
  end
  
  def create
    @order = AdvancedOrder.new(params[:order])
    if @order.save
      @order = AdvancedOrder.find(@order)
      pre_data_for_show_edit
      redirect_to @order 
    else
      keep_data_when_save_error
      render :action => "new"
    end
  end
  
  def update
    @order = AdvancedOrder.find(params[:id])
    if @order.update_attributes(params[:order])
      @order = AdvancedOrder.find(@order)
      pre_data_for_show_edit
      render :action => 'show'
    else
      keep_data_when_save_error
      render :action => "edit"
    end
  end
  
  def cancle
    @order = AdvancedOrder.find(params[:id])
    @order.destroy
    redirect_to("/book_records?date=#{Date.today.to_s(:db)}", :notice => '取消成功')
  end
  
  private
  
  def keep_data_when_save_error
    @member       = @order.member
    @member_cards = @member.member_cards if @member
    @current_card = @order.member_card
    @coaches = Coach.all
  end
  
  def pre_data_for_show_edit
    @order    ||=  AdvancedOrder.find(params[:id])
    @coaches  = Coach.all
    @courts   = Court.all
    @member       = @order.member
    @member_cards = @member.member_cards
    @current_card = @order.member_card
  end
  
end
