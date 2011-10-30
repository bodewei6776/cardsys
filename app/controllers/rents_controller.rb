class RentsController < ApplicationController
  def index
    @rents = Rent.all
    @lockers = Locker.all
    @current_date = params[:date].present? ? Date.parse(params[:date]) :  Date.today 
    @predate = @current_date - 1
    @nextdate = @current_date + 1
  end

  def show
    @rent = Rent.find(params[:id])
  end

  def new
    @locker = Locker.find(params[:locker_id])
    @rent = @locker.rents.build

    @rent.is_member = true 
    @rent.member = Member.new
    @rent.member_card = MemberCard.new
    @rent.start_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @rent.pay_way = Balance::Balance_Way_Use_Card

    render :layout => "small_main"
  end

  def edit
    @locker = Locker.find(params[:locker_id])
    @rent = Rent.find(params[:id])
  end

  def create
    @rent = Rent.new(params[:rent])

    respond_to do |format|
      if @rent.save && @rent.pay
        desc = "#{@rent.member_name}支付储物柜金额#{@rent.total_fee}"
         log_action(desc,"balance")

        format.html do
          render_js(" window.close(); if (window.opener && !window.opener.closed) {  " + 
                    " window.opener.location.reload(); } ")
        end
      else
        @locker = @rent.locker
        @rent.member = Member.find_by_name(params[:rent][:member_name]) || Member.new
        @rent.member_card = MemberCard.find_by_id(params[:rent][:card_num]) || MemberCard.new
        @rent.pay_way ||= Balance::Balance_Way_Use_Card
        render :action => "new" , :layout => "small_main"
      end
    end
  end

  def update
    @rent = Rent.find(params[:id])

    if @rent.update_attributes(params[:rent])
      redirect_to(rents_path, :notice => '续租成功.') 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @rent = Rent.find(params[:id])
    @rent.destroy
    redirect_to rents_url
  end

  def complete_member_infos
    if params[:id] =~ /^\d/
      @member = Member.find(params[:id])
      @cards = @member.member_cards
      @current_card = @cards.first
    else
      @current_card = MemberCard.find_by_card_serial_num(params[:id])
      @member = @current_card.member
      @cards = @member.member_cards
    end
    @date = Date.parse(params[:start_date])
    @rent = Rent.new(:member => @member,:member_card => @current_card,:start_date=> @date)
  end
end
