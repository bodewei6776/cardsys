class AdvancedOrdersController < ApplicationController

  layout  'main'

  def new
    @order    = AdvancedOrder.new 
    @coaches  = Coach.default_coaches
    @courts   = Court.all(:conditions => {:status => 1})
    @book_record = BookRecord.new
  end

  def show
    pre_data_for_show_edit
  end

  def edit
    pre_data_for_show_edit
  end

  def create
    @coaches  = Coach.default_coaches
    @courts   = Court.all(:conditions => {:status => 1})
    @order = AdvancedOrder.new(params[:order])

    if params[:user_name].blank? or params[:password].blank?
      @order.errors.add(:base,"预定人，密码不能为空")
      render :action => "new"#,:layout => 'small_main'
      return
    end
    user = User.find_by_login(params[:user_name])

    if user.blank? or !user.valid_password?(params[:password])
      @order.errors.add(:base,"用户不存在或者密码不正确")
      render :action => "new"#,:layout => 'small_main'
      return
    end


    unless user.can?('新场地预定')
      @order.errors.add(:base,"用户没有权限预定场地")
      render :action => "new"#,:layout => 'small_main'
      return
    end




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
    @coaches  = Coach.default_coaches
  end

  def pre_data_for_show_edit
    @order    ||=  AdvancedOrder.find(params[:id])
    @coaches  = Coach.default_coaches
    @courts   = Court.all(:conditions => {:status => 1}) 
    @member       = @order.member
    @member_cards = @member.member_cards
    @current_card = @order.member_card
  end

end
