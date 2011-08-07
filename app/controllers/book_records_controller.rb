class BookRecordsController < ApplicationController
  NO_NEED_CHECK_USER_AND_RIGHTS_OPERATION = %w{active}

  layout  'main'

  # GET /book_records
  # GET /book_records.xml
  def index
    @courts       = Court.all(:conditions => {:status => 1}) #Court.order('id').all
    @date = params[:date].blank? ? Date.today : Date.parse(params[:date])
    @daily_periods   = PeriodPrice.all_periods_in_time_span(@date)
    @predate      = @date.yesterday.strftime("%Y-%m-%d")
    @nextdate     = @date.tomorrow.strftime("%Y-%m-%d")    
  end

  def print
    @courts       = Court.order('id').all
    @date = params[:date].blank? ? Date.today : Date.parse(params[:date])
    @daily_periods   = PeriodPrice.all_periods_in_time_span(@date)
    render :layout => false

  end

  # GET /book_records/1
  # GET /book_records/1.xml
  def show
    @book_record = BookRecord.find(params[:id])
  end

  # GET /book_records/new
  # GET /book_records/new.xml
  def new    
    @court = Court.find(params[:court_id])
    @coaches = Coach.default_coaches
    @book_record = BookRecord.new
    @book_record.court = @court
    @book_record.start_hour = params[:start_hour]
    @book_record.end_hour =   params[:end_hour]
    @book_record.record_date = params[:date]
    @date = @book_record.record_date
    @order = Order.new
    @order.book_record  = @book_record
    render :layout => 'small_main'
  end

  # GET /book_records/1/edit
  def edit
    @book_record = BookRecord.find(params[:id])
    @order = @book_record.order
    @good_items = @order.product_items
    @non_member  = @order.non_member
    @member      = @order.member
    @member_cards = @member.member_cards if @member
    @court = @book_record.court || Court.find(@book_record.court_id)
    @current_card        = @order.member_card
    @coaches = Coach.default_coaches
    @date = @book_record.record_date
    render :action => "edit"
  end

  # POST /book_records
  # POST /book_records.xml
  def create
    @order = Order.new(params[:order])
    user = User.find_by_login(params[:user_name])
    if need_check_user_and_rights(params)
      if params[:user_name].blank? or params[:password].blank?
        @order.errors.add(:base,"预定人，密码不能为空")
        inite_related_order_objects
        render :action => "new",:layout => 'small_main'
        return
      end

      if user.blank? or !user.valid_password?(params[:password])
        @order.errors.add(:base,"用户不存在或者密码不正确")
        inite_related_order_objects
        render :action => "new",:layout => 'small_main'
        return
      end


      unless user.can?('新场地预定')
        @order.errors.add(:base,"用户没有权限预定场地")
        inite_related_order_objects
        render :action => "new",:layout => 'small_main'
        return
      end
    end

    @order.parent_id = 0
    @order.user_id = user.id
    respond_to do |format|
      if @order.save
        log_action("预定场地#{@order.book_record.court.name}","book", user)

        format.html { 
          render_js(" window.close(); if (window.opener && !window.opener.closed) {  " + 
                    " window.opener.location.reload(); } ")
        }
      else
        inite_related_order_objects
        format.html { render :action => "new",:layout => 'small_main' }
      end
    end
  end

  # PUT /book_records/1
  # PUT /book_records/1.xml
  def update
    @order = BookRecord.find(params[:id]).order

    user = User.find_by_login(params[:user_name])
    if need_check_user_and_rights(params)
      if params[:user_name].blank? or params[:password].blank?
        @order.errors.add(:base,"预定人，密码不能为空")
        inite_related_order_objects
        render :action => "edit"#,:layout => 'small_main'
        return
      end

      if user.blank? or !user.valid_password?(params[:password])
        @order.errors.add(:base,"用户不存在或者密码不正确")
        inite_related_order_objects
        render :action => "edit"#,:layout => 'small_main'
        return
      end


      unless user.can?('修改场地')
        @order.errors.add(:base,"用户没有权限修改场地")
        inite_related_order_objects
        render :action => "edit"#,:layout => 'small_main'
        return
      end

    end


    respond_to do |format|
      operation = params[:order][:operation].to_sym
      if ["consecutive_book","consecutive_cancle"].include?(params[:order][:operation])
        break unless @order.is_advanced_order?
        @orders =  @order.order_and_order_after
        params[:order][:operation] = params[:order][:operation].sub("consecutive_","")
        log_action("场地<#{@order.book_record.court.name}>#{BookRecord::OPERATION_MAP[operation]}",operation.to_s) if operation && BookRecord::OPERATION_MAP.keys.include?(operation)
        @orders.each { |o| o.update_attributes(params[:order]) }
        redirect_to("/book_records?date=#{@order.book_record.record_date.to_s(:db)}", :notice => '修改成功.') 
        return
      end

      if @order.update_attributes(params[:order])
        log_action("场地<#{@order.book_record.court.name}>#{BookRecord::OPERATION_MAP[operation]}",operation.to_s) if operation && BookRecord::OPERATION_MAP.keys.include?(operation)
        format.html { redirect_to("/book_records?date=#{@order.book_record.record_date.to_s(:db)}", :notice => '修改成功.') }
      else
        inite_related_order_objects
        format.html { render :action => "edit" }
      end
    end
  end

  def agent
    @original_book_record = BookRecord.find(params[:id])
    attributes = @original_book_record.attributes.except(:id,:status).merge({:status => BookRecord::Status_Do_Agent})
    @book_record = BookRecord.new(attributes)
    @court = @original_book_record.court
    @coaches = Coach.default_coaches
    @order = Order.new


    if request.post?
      if params[:user_name].blank? or params[:password].blank?
        @order.errors.add(:base,"预定人，密码不能为空")
        render :action => "edit"#,:layout => 'small_main'
        return
      end
      user = User.find_by_login(params[:user_name])

      if user.blank? or !user.valid_password?(params[:password])
        @order.errors.add(:base,"用户不存在或者密码不正确")
        render :action => "edit"#,:layout => 'small_main'
        return
      end
    end



    @order.operation = :agent
    @order.book_record  = @book_record
    @date = @book_record.record_date
    render :action => "agent"
  end

  def do_agent
    @original_book_record = BookRecord.find(params[:id])
    original_order = BookRecord.find(params[:id]).order
    @order = Order.new(params[:order])

    if params[:user_name].blank? or params[:password].blank?
      @order.errors.add(:base,"操作人，密码不能为空")
      inite_related_order_objects
      render :action => "agent"#,:layout => 'small_main'
      return
    end
    user = User.find_by_login(params[:user_name])

    if user.blank? or !user.valid_password?(params[:password])
      @order.errors.add(:base,"用户不存在或者密码不正确")
      inite_related_order_objects
      render :action => "agent"#,:layout => 'small_main'
      return
    end



    @order.operation = BookRecord.default_operation
    @order.parent_id = 0
    if @order.save
      original_order.do_agent(@order)
      redirect_to("/book_records?date=#{@order.book_record.record_date.to_s(:db)}", :notice => '代买改成功.')
    else
      inite_related_order_objects
      render :action => "agent"
    end
  end

  def cancle_agent
    book_record = BookRecord.find(params[:id])
    book_record.cancle_agent
    redirect_to("/book_records?date=#{book_record.record_date.to_s(:db)}", :notice => '取消代买成功.')
  end


  # DELETE /book_records/1
  # DELETE /book_records/1.xml
  def destroy
    book_record = BookRecord.find(params[:id])
    @order = book_record.order
    user = User.find_by_login(params[:user_name])

    respond_to do |format|
      if user.valid_password?(params[:password]) && user.can?("删除场地预定")
        if @order.is_advanced_order?
          @order.order_and_order_after.collect(&:destroy)
        else
          @order.destroy
        end
        format.js { render :json => {"result" => "0"}}
        format.html { redirect_to book_records_path}
      else
        format.js { render :json => {"result" => "1" }}
        format.html { redirect_to book_records_path}
      end

    end
  end

  def complete_for_members
    if (member_name = params[:term]).blank?
      render(:text => {}.to_json) && return
    end
    #    @members = Member.where(:status => CommonResource::MEMBER_STATUS_ON).where(["LOWER(name_pinyin) LIKE :member_name or LOWER(name) like :member_name or LOWER(pinyin_abbr) like :member_name",
    #                                                                               {:member_name => "#{member_name.downcase}%"}]).order("name_pinyin asc").limit(10)

    @members = Member.autocomplete_for(member_name)
    hash_results = @members.collect {|member| {"id" => member.id, "label" => "#{member.name} #{member.mobile}", 
      "value" => "#{member.name}"} }
    render :json  => hash_results
  end

  def complete_for_member_card
    if (card_nmuber = params[:term]).blank?
      render(:text => {}.to_json) && return
    end
    @member_cards = MemberCard.where(["LOWER(card_serial_num) like ?", "%#{card_nmuber.downcase}%"]).limit(10)
    hash_results = @member_cards.collect {|member_card| {"id" => member_card.card_serial_num, "label" => member_card.card_serial_num, 
      "value" => member_card.card_serial_num} }
    render :json  => hash_results
  end

  def complete_member_infos
    entry = Member.find_by_id(params[:id]) || MemberCard.where(:card_serial_num => params[:id]).first
    date = params[:date] || Date.today
    if entry
      if entry.is_a?(Member)
        member = entry
        member_cards = member.member_cards
        current_card = params[:current_card_serial_num].blank? ?   member_cards.first :
          member.member_cards.first(:conditions => "card_serial_num='#{params[:current_card_serial_num]}'")
      else
        member = entry.member
        member_cards = member.member_cards
        current_card = entry
      end
      render :partial => "/book_records/serial_num",
        :locals => {:member_cards => member.member_cards,:member => member,:current_card => current_card,:date => date}
    else
      render :nothing => true
    end
    return true
  end

  def change_card
    member_card = MemberCard.find_by_serial_num(params[:card_nmber])
    member  = member_card.member
    render :partial => "/book_records/serial_num",:locals => {:cards => member.cards,:member => member,
      :current_card => current_card}
  end

  def recalculate_court_amount
    reply = if [:date,:start_hour,:end_hour,:court_id].any?{|p| params[p].blank?}
              ''
            else
              court = Court.find(params[:court_id])

              court.calculate_amount_in_time_span(Date.parse(params[:date]),params[:start_hour],params[:end_hour])
            end
    render :text => reply
  end

  protected

  def need_check_user_and_rights(params)
    operation = params[:order][:operation]
    !NO_NEED_CHECK_USER_AND_RIGHTS_OPERATION.include?(operation)
  end


  def inite_related_order_objects
    @non_member  = @order.non_member
    @member      = @order.member
    @good_items  = @order.product_items
    @member_cards = @member.member_cards if @member
    @book_record = @order.book_record
    @court = @book_record.court || Court.find(@book_record.court_id)
    @current_card        = @order.member_card
    @coaches = Coach.default_coaches
  end
end
