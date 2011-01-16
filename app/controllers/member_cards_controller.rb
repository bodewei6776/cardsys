class MemberCardsController < ApplicationController

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
#     @p = params[:p]
#     @name = params[:name]
     @member_name = params[:member_name]
     @serial_num = params[:card_serial_num]
#     @member_cards = MemberCard.order('card_serial_num')
      p '---'
      p params[:p] 
     if !@member_name.blank?
       @serial_num = "" if params[:p].nil?
       member = Member.where(:name => @member_name).where(:status => CommonResource::MEMBER_STATUS_ON).first
       if member.nil?
         @member_cards = []
       else
         @member_cards = MemberCard.where(:member_id => member.id)
       end
     end
     if "num" == params[:p] && !@serial_num.blank?
       #@member_cards 只有一个值
       @member_cards = [MemberCard.where(:card_serial_num => @serial_num).first]
       @member_card = @member_cards.first
     end
#     @member_cards = @member_cards.paginate(:page => params[:page]||1,:per_page => Member_Perpage)

#     if @p =="index1"
#       @member_card = nil
#       @member_cards = []
#     end
     respond_to do |format|
       format.html # index.html.erb
       format.xml  { render :xml => @member_cards }
     end
  end

  def show
     @member_card = MemberCard.find(params[:id])
     render :layout => false
  end

#  def to_recharge
#    @member_card = MemberCard.find(params[:id])
#    @type = params[:type]
#    render :layout => false
#  end
end
