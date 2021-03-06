# -*- encoding : utf-8 -*-
class MembersCardsController < ApplicationController


  autocomplete :members, :name

  def index
    @members_cards = MembersCard.paginate default_paginate_options
  end


  def autocomplete_name
    @items = Member.autocomplete_for(params[:term])
    @names = []
    @items.each { |i| @names << i.name }
    render :inline => @names.to_json
  end

  def autocomplete_card_serial_num
    @items = MembersCard.autocomplete_for(params[:term])
    render :json => @items.collect{|item|
      {:member_name => item.member.name, 
        :value => item.card_serial_num,
        :label => item.card_serial_num,
        :member_id => item.member_id,
        :id => item.id}}
  end

  def recharge_form
    @members_card = MembersCard.find_by_card_serial_num(params[:card_serial_num])
    params[:member_name] = @members_card.try(:member).try(:name)
    render :layout => false
  end

  def recharge
    @members_card = MembersCard.find_by_card_serial_num(params[:card_serial_num])
    params[:member_name] = @members_card.try(:member).try(:name)
  end

  def new
    if params[:card_serial_num]
      @member_card = MembersCard.find_by_card_serial_num(params[:card_serial_num])
      @member = @member_card.member
    elsif params[:member_name]
      @member = Member.find_by_name(params[:member_name])
    end
    @cards = Card.enabled
    @members_card = MembersCard.new(:member_id => @member.try(:id), 
                                    :expire_date => 6.month.from_now,
                                    :left_fee => 0,
                                    :left_times => 0)
    @members_cards = @member.try(:all_members_cards) || []
  end

  def create
    @members_card = MembersCard.new(params[:members_card])
    if @members_card.save
      log_action(@members_card, "kaika", @members_card.user || current_user)
      flash[:notice] = "会员卡创建成功"
    else
      @members_cards = []
      render new_members_card_path
      return
    end
    redirect_to members_cards_path# new_members_card_path(:card_serial_num => @members_card.card_serial_num)
  end

  def update
    @members_card = MembersCard.find(params[:id])
    if @members_card.update_attributes(params[:members_card])
      if params[:commit] == "充值"
        log_action(@members_card, "chongzhi", @members_card.user || current_user, "#{params[:members_card][:recharge_fee]}元，#{params[:members_card][:recharge_times]}次")
        flash[:notice] = "会员卡充值成功, 卡内总值为#{@members_card.left_fee}, 卡内次数#{@members_card.left_times}"
        @members_card.recharge_records.create(:member_id => @members_card.member_id,
                                              :recharge_fee => params[:members_card][:recharge_fee],
                                              :recharge_times => params[:members_card][:recharge_times],
                                              :recharge_person_name => @members_card.user.try(:user_name) || current_user.user_name)
      end
      redirect_to recharge_members_cards_path(:card_serial_num => @members_card.card_serial_num)
    else
      params[:member_name] = @members_card.member.name
      params[:card_serial_num] = @members_card.card_serial_num
      render :action => "recharge"
    end
  end

  def destroy
    @members_card = MembersCard.find  params[:id]
    @name = @members_card.member.name
    if @members_card.destroy
      flash[:notice] = "会员卡删除成功"
    end

    redirect_to :action => "new", :member_name => @name
  end

  def show
    @members_card = MembersCard.find(params[:id])
    respond_to do |wants|
      wants.html { render :layout => false }
      wants.json { render :json => {
        :card_type_in_chinese => @members_card.card_type_in_chinese,
        :remaining_money_and_amount_in_chinese => @members_card.remaining_money_and_amount_in_chinese,
        :members_card_info => @members_card.members_card_info,
        :mobile => @members_card.member.mobile,
        :id => @members_card.id
      }
      
      
      } 
    end
  end

  def granters 
    @members_card = MembersCard.find_by_card_serial_num params[:card_serial_num]
    params[:member_name] = @members_card.try(:member).try(:name)
  end


  def granter_form 
    @members_card = MembersCard.find_by_card_serial_num(params[:card_serial_num])
    params[:member_name] = @members_card.try(:member).try(:name)
    render :layout => false
  end


  def status
    conditions = {}
    @members_cards = MembersCard.where(conditions).paginate(default_paginate_options)
  end

  def status_html
    conditions = {}
    if params[:card_serial_num].present?
      conditions.merge!(:card_serial_num => params[:card_serial_num])
    end

    @members_cards = MembersCard.where(conditions).paginate(default_paginate_options)
    render :layout => "small_main"
  end


  def switch_state
    @card = MembersCard.find(params[:id])
    @card.switch_state!
    redirect_to :back
  end

end
