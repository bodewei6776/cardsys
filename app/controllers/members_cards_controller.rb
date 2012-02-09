class MembersCardsController < ApplicationController


  autocomplete :members, :name


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

  def recharge
    if params[:card_serial_num]
      @members_card = MembersCard.find_by_card_serial_num(params[:card_serial_num])
      @member = @members_card.member
      params[:member_name] = @member.name
    else 
      @members_card = []
    end
  end

  def new
    @member = Member.find_by_name(params[:member_name])
    @cards = Card.enabled
    @members_card = MembersCard.new(:member_id => @member.try(:id), :expire_date => 6.month.from_now)
    @members_cards = @member.try(:all_members_cards) || []
  end

  def create
    @members_card = MembersCard.new(params[:members_card])
    if @members_card.save
      flash[:notice] = "会员卡创建成功"
    else
      render :action => "new"
      return
    end
    redirect_to :action => "new", :member_name => @members_card.member.name
  end

  def update
    @members_card = MembersCard.find(params[:id])
    if @members_card.update_attributes(params[:members_card])
      redirect_to :action => "recharge", :card_serial_num => @members_card.card_serial_num
    else
      params[:member_name] = @members_card.member.name
      render :action => "recharge"
    end
  end


  def show
    @members_card = MembersCard.find(params[:id])
    respond_to do |wants|
      wants.html { render :layout => false }
      wants.json { render :json => {
        :card_type_in_chinese => @members_card.card_type_in_chinese,
        :remaining_money_and_amount_in_chinese => @members_card.remaining_money_and_amount_in_chinese,
        :members_card_info => @members_card.members_card_info,
        :mobile => @members_card.member.mobile
      }} 
    end
  end

  def granters 
    @members_card = MembersCard.find_by_card_serial_num params[:card_serial_num]
    params[:member_name] = @members_card.try(:member).try(:name)
  end


  def status
    conditions = {}
    if params[:name].present? and Member.find_by_name(params[:name]).present?
      conditions.merge!(:member_id => Member.find_by_name(params[:name]).id)
    end

    if params[:card_serial_num].present?
      conditions.merge!(:card_serial_num => params[:card_serial_num])
    end
    @members_cards = MembersCard.where(conditions).paginate(default_paginate_options)
  end


  def switch_state
    @card = MembersCard.find(params[:id])
    @card.switch_state!
    redirect_to :back
  end

end
