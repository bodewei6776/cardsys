class MemberCardsController < ApplicationController

  layout 'main'

  autocomplete :members, :name

  Member_Perpage = 15

  def autocomplete_name
    @items = Member.where(["pinyin_abbr like ? or name_pinyin like ? or name like ?", "%#{params[:term].downcase}%", "%#{params[:term].downcase}%", "%#{params[:term]}%" ]).where(:status => CommonResource::MEMBER_STATUS_ON).limit(10)
    @names = []
    @items.each { |i| @names << i.name }
    render :inline => @names.to_json#{lable:name, value:name}
  end

  def autocomplete_card_serial_num
    @items = MemberCard.where(["card_serial_num like ?", "%#{params[:term].downcase}%"]).limit(10)
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
    if "num" == params[:p] && !@serial_num.blank?
      @member_cards = [MemberCard.where(:card_serial_num => @serial_num).first]
      @member_card = @member_cards.first
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @member_cards }
    end
  end

  def show
    @member_card = MemberCard.find(params[:id])
    render :layout => false
  end

end
