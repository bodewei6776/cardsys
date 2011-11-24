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
      {:order_tip_message => item.order_tip_message,
                                     :can_buy_good => item.can_buy_good,
                                     :member_info => item.member_info,
                                     :card_info => item.card_info,
                                     :member_id => item.member_id,
                                     :member_name => item.member_name,
                                     :value => item.card_serial_num,
                                     :label => item.card_serial_num}}
  end

  def search
    @member_name = params[:member_name]
    @serial_num = params[:card_serial_num]
    if !@member_name.blank?
      @serial_num = "" if params[:p].blank?
      member = Member.where(:name => @member_name).where(:status => CommonResource::MEMBER_STATUS_ON).first
      @member_cards = MembersCard.where(:member => member)
    end
    @member_card =  MembersCard.new
    if "num" == params[:p] && !@serial_num.blank?
      @member_cards = [MembersCard.where(:card_serial_num => @serial_num).first]
      @member_card = @member_cards.present? ? @member_cards.first : MembersCard.new
    end
  end

  def show
    @member_card = MembersCard.find(params[:id])
    render :layout => false
  end

  def granters 
    @member_name = params[:member_name]
    @serial_num = params[:card_serial_num]
    if !@member_name.blank?
      @serial_num = "" if params[:p].blank?
      member = Member.where(:name => @member_name).where(:status => CommonResource::MEMBER_STATUS_ON).first
      if member.nil?
        @member_cards = []
      else
        @member_cards = MembersCard.where(:member_id => member.id)
      end
    end
    @member_card =  MembersCard.new
    if "num" == params[:p] && !@serial_num.blank?
      @member_cards = [MembersCard.where(:card_serial_num => @serial_num).first]
      @member_card = @member_cards.present? ? @member_cards.first : MembersCard.new
    end
    respond_to do |format|
      format.xml  { render :xml => @member_cards }
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
    @member_cards = MembersCard.where(conditions).paginate(default_paginate_options)
  end


  def switch
    @card = MembersCard.find(params[:id])
    @card.status = @card.enable? ? 1 : 0
    @card.save
    redirect_to status_member_cards_path(:name => params[:name],:card_serial_num => params[:card_serial_num])
  end

end
