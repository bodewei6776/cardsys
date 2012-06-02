# -*- encoding : utf-8 -*-
class MembersController < ApplicationController

  before_filter :get_granters, :only => [:granter_index]
  autocomplete :members, :name


  def autocomplete_name
    @items = Member.autocomplete_for(params[:term])
    @names = []
    @items.each { |i| @names << {:value => i.name,:label => "#{i.name} - #{i.mobile}", :id => i.id} }
    render :inline => @names.to_json
  end

  def autocomplete_card_serial_num
    @items = MembersCard.autocomplete_for(params[:term])
    @names = []
    @items.each { |i| @names << i.card_serial_num }
    render :inline => @names.to_json
  end

  def index
    @members = Member.scoped
    @members = @members.where(:name => params[:name]) if params[:name].present?
    @members = @members.where("member_cards.card_serial_num = '#{params[:card_serial_num]}'").joins(:members_cards) if params[:card_serial_num].present?
    @members = @members.paginate(default_paginate_options)
  end

  def advanced_search 
    @name = params[:name]#会员名
    @serial_num = params[:card_serial_num]#会员卡号
    @reg_date_start = params[:reg_date_start]#注册日期
    @reg_date_end = params[:reg_date_end]
    @expire_date_start = params[:expire_date_start]#会员卡有效期
    @expire_date_end = params[:expire_date_end]

    @comer_date_start = params[:comer_date_start]#来店日期
    @comer_date_end = params[:comer_date_end]
    @consume_count_start = params[:consume_count_start]#刷卡次数 ???
    @consume_count_end = params[:consume_count_end]
    @consume_fees_start = params[:consume_fees_start]#消费金额
    @consume_fees_end = params[:consume_fees_end]
    @left_fees_start = params[:left_fees_start]#卡内余
    @left_fees_end = params[:left_fees_end]
    @left_times_start = params[:left_times_start]#现有次数
    @left_times_end = params[:left_times_end]
    @member_birthday_start = params[:member_birthday_start]#会员生日
    @member_birthday_end = params[:member_birthday_end]
    @member_gender = params[:member_gender]#会员性别

    @members = Member.enabled
    @members = @members.where(["name like ?", "%#{@name}%"] ) if !@name.blank?
    if !@serial_num.blank?
      @members = @members.where("member_cards.card_serial_num like '%#{@serial_num}%'").joins(:members_cards)
    end



    if @comer_date_start.present? &&  @comer_date_end.present?
      @members = @members.where("date_format(orders.order_time,'%Y-%m-%d') >= ? and " + 
                                " date_format(orders.order_time,'%Y-%m-%d') <= ?",
                                @comer_date_start,@comer_date_end).joins(:orders)
    elsif @comer_date_start.present? || @comer_date_end.present?
      @members = @members.where("date_format(orders.order_time,'%Y-%m-%d') = ?",
                                @comer_date_start.presence || @comer_date_end.presence).joins(:orders)
    end

    if @expire_date_start.present? && @expire_date_end.present?
      @members = @members.where("date_format(member_cards.expire_date,'%Y-%m-%d') >= ? and" +
                                " date_format(member_cards.expire_date,'%Y-%m-%d') <= ?",
                                @expire_date_start,@expire_date_end).joins(:members_cards)
    elsif @expire_date_start.present? || @expire_date_end.present?
      @members = @members.where("date_format(member_cards.expire_date,'%Y-%m-%d') = ?",
                                @expire_date_end.presence || @expire_date_start.presence).joins(:member_cards)
    end

    if @member_birthday_start.present? && @member_birthday_end.present?
      @members = @members.where("date_format(birthday,'%m-%d') >= ? and " +
                                "date_format(birthday,'%m-%d') <= ?", 
                                @member_birthday_start,@member_birthday_end)
    elsif @member_birthday_end.present? || @member_birthday_start.present?
      @members = @members.where("date_format(birthday,'%m-%d') = ?", 
                                @member_birthday_end.presence || @member_birthday_start.presence)
    end

    if @reg_date_start.present? && @reg_date_end.present?
      @members = @members.where("date_format(members.created_at,'%Y-%m-%d') >= ? and " +
                                "date_format(members.created_at,'%Y-%m-%d') <= ?",
                                @reg_date_start,@reg_date_end) 
    elsif @reg_date_end.present? || @reg_date_start.present?
      @members = @members.where("date_format(members.created_at,'%Y-%m-%d') = ?", 
                                @reg_date_end.presence || @reg_date_start.presence )
    end



    @members = @members.where("gender = ?", @member_gender) if !params[:member_gender].blank?
    if @consume_count_start.present? and @consume_count_end.present?
      @members = @members.delete_if { |mem| 
        mem.use_card_times < @consume_count_start.presence.to_i || mem.use_card_times > @consume_count_end.presence.to_i}
    elsif @consume_count_start.present? or @consume_count_end.present?
      @members = @members.delete_if { |mem| 
        mem.use_card_times != (@consume_count_start.presence.to_i ||  @consume_count_end.presence.to_i)}
    end

    if @left_fees_start.present? and @left_fees_end.present?
      @members = @members.delete_if { |mem| 
        mem.members_card_left_fees < @left_fees_start.presence.to_i || mem.members_card_left_fees > @left_fees_end.presence.to_i}

    elsif @left_fees_start.present? or @left_fees_end.present?
      @members = @members.delete_if { |member| member.members_card_left_fees !=( @left_fees_start.presence.to_i || @left_fees_end.presence.to_i )}
    end


    if @left_times_start.present? and @left_times_end.present?
      @members = @members.delete_if { |member| member.members_card_left_times < @left_times_start.to_i || member.members_card_left_times > @left_times_end.presence.to_i}
    elsif @left_times_start.present? or @left_times_end.present?
      @members = @members.delete_if { |member| member.members_card_left_times !=( @left_times_start.presence ||  @left_times_end.presence).to_i}
    end

    if @consume_fees_start.present? and @consume_fees_end.present?
      @members = @members.delete_if { |member| member.member_consume_amounts < @consume_fees_start.presence.to_i || member.member_consume_amounts > @consume_fees_end.presence.to_i }
    elsif @consume_fees_start.present? or @consume_fees_end.present?
      @members = @members.delete_if { |member| member.member_consume_amounts !=( @consume_fees_start.presence.to_i || @consume_fees_end.presence.to_i)}
    end

    @members = @members.paginate(default_paginate_options )
  end



  def show
    @member = Member.find(params[:id])
    @members_cards = @member.all_members_cards
    @recharge_records = RechargeRecord.where(:member_id => params[:id])
    @balances = @member.balances
  end

  def new
    @member = Member.new(:gender => CommonResource::Gender_Man)
    @member.granter = true if params[:members_card_id]
    @member.members_card_id = params[:members_card_id] if params[:members_card_id]
  end

  def edit
    @member = Member.find(params[:id])
  end

  def create
    @member = Member.new(params[:member])
    if @member.save
      if @member.granter?
        redirect_to new_members_card_path(:member_name => @member.name)
      else
        flash[:notice] = "会员信息添加成功"
        redirect_to members_path
      end
    else
      render :new
    end
  end

  def update
    @member = Member.find(params[:id])
    is_member = params[:member][:is_member]
    respond_to do |format|
      if @member.update_attributes(params[:member])
        if CommonResource::IS_GRANTER.to_s.eql?(is_member)
          @member_base = Member.find(params[:member_id])
          format.html { redirect_to :action => "granter_index", :member_id => params[:member_id], :notice => '授权人信息修改成功！'}
        else
          format.html { redirect_to edit_member_path(@member), :notice => '会员信息修改成功！' }
        end
      else
        if CommonResource::IS_GRANTER.to_s.eql?(is_member)
          @member_base = Member.find(params[:member_id])
          format.html { render :action => "granter_edit" }
        else
          format.html { render :action => "edit" }
        end
      end
    end
  end

  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    redirect_to(members_url) 
  end

  def granter_index
    @member = Member.find(params[:member_id])
    @notice = params[:notice]
  end

  def granter_new
    @member = Member.new
    @member_base = Member.find(params[:member_id])
    @members_card_id = params[:members_card_id]
    render :layout => false
  end

  def granter_edit
    @member = Member.find(params[:granter_id])
    @member_base = Member.find(params[:member_id])
  end

  def granter_delete
    @mb = Member.find(params[:member_id])
    @member_granter = MembersCardGranter.where(:granter_id => params[:granter_id]).first
    @member_granter.destroy if !@member_granter.nil?

    @member = Member.find(params[:granter_id])
    @member.destroy

    redirect_to :action => 'granter_index', :member_id => params[:member_id], :notice => '授权人删除成功！' 
  end

  def granter_show
    @granter = Member.find(params[:id])
    @base_member = Member.find(params[:member_id]) if !params[:member_id].nil?
  end

  def members_card_bind_index
    @member = Member.find_by_name(params[:member_name])
    @cards = Card.enabled
    @members_card = MembersCard.new
    @members_cards = @member.try(:all_members_cards) 
  end

  def members_card_bind_list
    @member = Member.find(params[:member_id])
    @cards = Card.enabled
    render :layout => false
  end

  def members_card_bind_update
    @member = Member.find(params[:member_id])
    @members_card = MembersCard.new(params[:members_card])
    @members_card.member_id = params[:member_id]
    @members_card.card_id = params[:binded_card_id]
    @members_card.user_id = current_user.id
    @members_card.password = @member.name
    notice = @members_card.save ? '会员卡绑定成功！' : @members_card.errors.full_messages.join(';')
    respond_to do |format|
      format.html { redirect_to :action => "members_card_bind_index",
        :member_name => @member.name, :member_id => params[:member_id], :notice => notice}
    end
  end

  def members_card_index
    @member = Member.find(params[:member_id])
    @members_cards = MembersCard.where(:member_id => params[:member_id])
    render :layout => false
  end

  def members_card_recharge
    user = User.find_by_login(params[:user])
    result = true
    unless user
      notice = {:result => 0,:notice =>"用户名不存在"}
      result = false
    end

    unless user.valid_password?(params[:password])
      notice = {:result => 0,:notice => "密码不正确"}
      result = false
    end

    unless user.can?("会员卡充值")
      notice = {:result => 0,:notice => "用户无权限"}
      result = false
    end

    unless result
      render :json => notice
      return
    end


    fee = (params[:fee].blank? ? 0 : params[:fee])
    times = (params[:times].blank? ? 0 : params[:times])

    members_card = MembersCard.find(params[:members_card_id])
    charge_fee = params[:type]=="1" ? fee.to_f : (-fee.to_f)
    charge_times = params[:type]=="1" ? times.to_f : (-times.to_f)

    if (members_card.update_attribute(:left_fee, members_card.left_fee.to_f + charge_fee) &&
        members_card.update_attribute(:left_times, members_card.left_times.to_f + charge_times))
      RechargeRecord.new(:member_id => members_card.member_id,
                         :members_card_id => members_card.id,
                         :recharge_times=> charge_times,
                         :recharge_fee => charge_fee,
                         :recharge_person => user.id
                        ).save

                        log_action(members_card, "recharge", current_user, "#{charge_fee}元，#{charge_times}次")


                        notice = ""
                        notice << "会员卡充值成功" if charge_fee > 0
                        notice << "，会员卡充次成功" if charge_times > 0


    end
    if !params[:expire_date].blank?
      members_card.update_attribute(:expire_date, params[:expire_date])
      notice = "有效期修改成功！"
    end
    render :json => {:result => 1,:notice => notice }
  end

  def get_members
    @items = Member.where(["name = ?", "#{params[:name].downcase}"]).where(:status => CommonResource::MEMBER_STATUS_ON).limit(1)
    @ids = []
    @items.each { |i| @ids << i.id }
    render :inline => @ids.to_json
  end

  def member_cards_list
    @card_list = Member.find(params[:id]).all_members_cards
    render :json => @card_list.to_json(:only => [:id, :card_serial_num],:methods => [ :card_type_in_chinese, :remaining_money_and_amount_in_chinese, :members_card_info])
  end

  def switch_state
    @member = Member.find(params[:id])
    @member.switch_state!
    @member.state
    redirect_to(members_path) 
  end


  private

  def get_granters
    @members_card_granters = MembersCardGranter.where(:member_id => params[:member_id])
    options = []
    @members_card_granters.each { |members_card_granter| options << members_card_granter.granter_id }
    @granters = Member.where(["id IN(?)", options]).where(:is_member => CommonResource::IS_GRANTER)
  end

end
