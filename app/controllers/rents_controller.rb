class RentsController < ApplicationController
  layout 'small_main'
  # GET /rents
  # GET /rents.xml
  def index
    @rents = Rent.all
    @lockers = Locker.all
    @current_date = params[:date].present? ? Date.parse(params[:date]) :  Date.today 
    @predate = @current_date - 1
    @nextdate = @current_date + 1

    respond_to do |format|
      format.html { render :layout => 'main'}# index.html.erb
      format.xml  { render :xml => @rents }
    end
  end

  # GET /rents/1
  # GET /rents/1.xml
  def show
    @rent = Rent.find(params[:id])

    respond_to do |format|
      format.html {render :layout => 'main'}
      format.xml  { render :xml => @rent }
    end
  end

  # GET /rents/new
  # GET /rents/new.xml
  def new
    @locker = Locker.find(params[:locker_id])
    @rent = @locker.rents.build
    
    @rent.is_member = true 
    @rent.member = Member.new
    @rent.member_card = MemberCard.new
    @rent.start_date = params[:date].present? ? Date.parse(params[:date]) : Date.today
    @rent.pay_way = Balance::Balance_Way_Use_Card

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rent }
    end
  end

  # GET /rents/1/edit
  def edit
    @locker = Locker.find(params[:locker_id])
    @rent = Rent.find(params[:id])
  end

  # POST /rents
  # POST /rents.xml
  def create
    @rent = Rent.new(params[:rent])

    respond_to do |format|
      if @rent.pay && @rent.save 
        desc = "#{@rent.member_name}支付储物柜金额#{@rent.total_fee}"
        log_action(desc,"balance")
        format.html { 
          render_js(" window.close(); if (window.opener && !window.opener.closed) {  " + 
                    " window.opener.location.reload(); } ")
        }      
      else
        @locker = @rent.locker
        @rent.member = Member.find_by_name(params[:rent][:member_name]) || Member.new
        @rent.member_card = MemberCard.find_by_id(params[:rent][:card_num]) || MemberCard.new
        @rent.pay_way ||= Balance::Balance_Way_Use_Card
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /rents/1
  # PUT /rents/1.xml
  def update
    @rent = Rent.find(params[:id])

    respond_to do |format|
      if @rent.update_attributes(params[:rent])
        format.html { redirect_to(rents_path, :notice => '续租成功.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rents/1
  # DELETE /rents/1.xml
  def destroy
    @rent = Rent.find(params[:id])
    @rent.destroy

    respond_to do |format|
      format.html { redirect_to(rents_url) }
      format.xml  { head :ok }
    end
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
    respond_to do |format|
      format.js {}
    end
  end
end
