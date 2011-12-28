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

  def search
    if params[:member_name]
      @members_cards = Member.find_by_name(params[:member_name]).try(:all_members_cards)
    elsif params[:card_serial_num]
      @members_cards = MembersCard.all(:conditions => {:card_serial_num => params[:card_serial_num]})
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
    @member_name = params[:member_name]
    @serial_num = params[:card_serial_num]
    if !@member_name.blank?
      @serial_num = "" if params[:p].blank?
      member = Member.where(:name => @member_name).first
      if member.nil?
        @members_cards = []
      else
        @members_cards = MembersCard.where(:member_id => member.id)
      end
    end
    @members_card =  MembersCard.new
    if "num" == params[:p] && !@serial_num.blank?
      @members_cards = [MembersCard.where(:card_serial_num => @serial_num).first]
      @members_card = @members_cards.present? ? @members_cards.first : MembersCard.new
    end
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


  def switch
    @card = MembersCard.find(params[:id])
    @card.status = @card.enable? ? 1 : 0
    @card.save
    redirect_to status_members_cards_path(:name => params[:name],:card_serial_num => params[:card_serial_num])
  end

end
