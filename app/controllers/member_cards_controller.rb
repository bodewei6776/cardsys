class MemberCardsController < ApplicationController

  layout 'main'

  autocomplete :members, :name

  Member_Perpage = 15

  def autocomplete_name
    @items = Member.autocomplete_for(params[:term])
    @names = []
    @items.each { |i| @names << i.name }
    render :inline => @names.to_json#{lable:name, value:name}
  end

  def autocomplete_card_serial_num
    #@items = MemberCard.where(["card_serial_num like ?", "%#{params[:term].downcase}%"]).limit(10)
    @items = MemberCard.autocomplete_for(params[:term])
    @names = []
    @items.each { |i| @names << i.card_serial_num }
    render :inline => @names.to_json
  end

  # GET /members
  # GET /members.xml
  def search
    @member_name = params[:member_name]
    @serial_num = params[:card_serial_num]
    if !@member_name.blank?
      @serial_num = "" if params[:p].blank?
      member = Member.where(:name => @member_name).where(:status => CommonResource::MEMBER_STATUS_ON).first
      if member.nil?
        @member_cards = []
      else
        @member_cards = MemberCard.where(:member_id => member.id)
      end
    end
      @member_card =  MemberCard.new
    if "num" == params[:p] && !@serial_num.blank?
      @member_cards = [MemberCard.where(:card_serial_num => @serial_num).first]
      @member_card = @member_cards.present? ? @member_cards.first : MemberCard.new
    end
      #@member_card = @member_cards.present? ? @member_cards.first : MemberCard.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @member_cards }
    end
  end

  def show
    @member_card = MemberCard.find(params[:id])
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
        @member_cards = MemberCard.where(:member_id => member.id)
      end
    end
    @member_card =  MemberCard.new
    if "num" == params[:p] && !@serial_num.blank?
      @member_cards = [MemberCard.where(:card_serial_num => @serial_num).first]
      @member_card = @member_cards.present? ? @member_cards.first : MemberCard.new
    end
    #@member_card = @member_cards.present? ? @member_cards.first : MemberCard.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @member_cards }
    end
  end


  # 停用启用会员卡
  def status
    conditions = {}#default_paginate_options
    if params[:name].present? and Member.find_by_name(params[:name]).present?
      conditions.merge!(:member_id => Member.find_by_name(params[:name]).id)
    end

    if params[:card_serial_num].present?
      conditions.merge!(:card_serial_num => params[:card_serial_num])
    end
    @member_cards = MemberCard.where(conditions).paginate(default_paginate_options)
  end


  def switch
    @card = MemberCard.find(params[:id])
    @card.status = @card.enable? ? 1 : 0
    @card.save
    redirect_to status_member_cards_path(:name => params[:name],:card_serial_num => params[:card_serial_num])
  end

end
