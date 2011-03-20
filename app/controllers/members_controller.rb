class MembersController < ApplicationController

  before_filter :get_granters, :only => [:granter_index]
  autocomplete :members, :name

  layout  'main'

  Member_Perpage = 15

  def autocomplete_name
    @items = Member.where(:status => CommonResource::MEMBER_STATUS_ON).where(:is_member => CommonResource::IS_MEMBER).where(["pinyin_abbr like ? or name_pinyin like ? or name like ?", "%#{params[:term].downcase}%", "%#{params[:term].downcase}%", "%#{params[:term]}%" ]).limit(10)
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

  def index

  end

  # GET /members
  # GET /members.xml
  def index
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
    @left_fees_end = params[:left_fees_start]
    @left_times_start = params[:left_times_start]#现有次数
    @left_times_end = params[:left_times_end]
    @member_birthday_start = params[:member_birthday_start]#会员生日
    @member_birthday_end = params[:member_birthday_end]
    @member_gender = params[:member_gender]#会员性别

    @members = Member.where(:status => CommonResource::MEMBER_STATUS_ON).where(:is_member => CommonResource::IS_MEMBER)
    @members = @members.where(["name like ?", "%#{@name}%"] ) if !@name.blank?
    if !@serial_num.blank?
      member = MemberCard.where(:card_serial_num => @serial_num).first
      @members = @members.where(:id => member.member.id) if !member.nil?
    end
    if !params[:comer_date_start].blank?
      order = Order.where("order_time >= ?", @comer_date_start).first
      @members = @members.where(:id => order.member_id) if !order.nil?
    end
    if !params[:comer_date_end].blank?
      order = Order.where("order_time <= ?", @comer_date_end).first
     @members = @members.where(:id => order.member_id) if !order.nil?
    end    
    ids = []    
    MemberCard.where("expire_date >= ?", @expire_date_start).each { |i| ids << i.member_id }if !params[:expire_date_start].blank?
    MemberCard.where("expire_date <= ?", @expire_date_end).each { |i| ids << i.member_id }if !params[:expire_date_end].blank?
    @members = @members.where("id in (?)", ids) if ids.size > 0

    @members = @members.where("birthday >= ?", @member_birthday_start) if !params[:member_birthday_start].blank?
    @members = @members.where("birthday <= ?", @member_birthday_end) if !params[:member_birthday_end].blank?

    @members = @members.where("gender = ?", @member_gender) if !params[:member_gender].blank?
    @members = @members.where("created_at >= ?", @reg_date_start ) if !params[:reg_date_start].blank?
    @members = @members.where("created_at <= ?", @reg_date_end ) if !params[:reg_date_end].blank?

     if !params[:consume_count_start].blank?
      @members = @members.delete_if { |mem| mem.use_card_times < @consume_count_start.to_i }
    end

    if !params[:consume_count_end].blank?
      @members = @members.delete_if { |mem| mem.use_card_times > @consume_count_end.to_i }
    end

    if !params[:left_fees_start].blank?
      @members = @members.delete_if { |member| member.member_card_left_fees < @left_fees_start.to_i }
    end

    if !params[:left_fees_end].blank?
      @members = @members.delete_if { |member| member.member_card_left_fees > @left_fees_end.to_i }
    end

    if !params[:left_times_start].blank?
      @members = @members.delete_if { |member| member.member_card_left_times < @left_times_start.to_i }
    end

    if !params[:left_times_end].blank?
      @members = @members.delete_if { |member| member.member_card_left_times > @left_times_end.to_i }
    end

    if !params[:consume_fees_start].blank?
      @members = @members.delete_if { |member| member.member_consume_amounts < @consume_fees_start.to_i }
    end

    if !params[:consume_fees_end].blank?
      @members = @members.delete_if { |member| member.member_consume_amounts > @consume_fees_end.to_i }
    end

    @members = @members.paginate(:page => params[:page]||1,:per_page => Member_Perpage)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @members }
    end
  end

  # GET /members/1
  # GET /members/1.xml
  def show
    @member = Member.find(params[:id])
    @member_cards = MemberCard.where(:member_id => params[:id])
    @recharge_records = RechargeRecord.where(:member_id => params[:id])#充值记录
    #@orders = Order.balanced.where(:member_id => params[:id])#消费记录的显示方式
    @balances = Balance.balanced.where(:member_id => params[:id]).paginate(:page => params[:page]||1)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end
  end

  # GET /members/new
  # GET /members/new.xml
  def new
    @member = Member.new
    respond_to do |format|
      format.html
      format.xml  { render :xml => @member }
    end
  end

  # GET /members/1/edit
  def edit
    @member = Member.find(params[:id])
  end

  # POST /members
  # POST /members.xml
  def create
    is_member = params[:member][:is_member]
    @member = Member.new(params[:member])
    @member.catena_id = session[:catena_id]
    respond_to do |format|
      if @member.save
        @members = Member.where(:is_member => is_member)
        if CommonResource::IS_GRANTER.to_s.eql?(is_member)
          base_member_id = params[:member_id]
          @member_base = Member.find(params[:member_id])
          @mg = MemberCardGranter.new(:member_id => base_member_id, :member_card_id => params[:member_card_id], :granter_id => @member.id, :catena_id => session[:catena_id])
          @mg.save
          format.html { redirect_to :action => "member_card_bind_index", :member_id => base_member_id, :member_name => @member_base.name, :notice => '授权人信息添加成功！'}
        else
          format.html { redirect_to :action => "index", :notice => '会员信息添加成功！'}
          format.xml  { render :xml => @member, :status => :created, :location => @member }
        end
      else
        if CommonResource::IS_GRANTER.to_s.eql?(is_member)
          @member_base = Member.find(params[:member_id])
          format.html { redirect_to :action => "member_card_bind_index", :member_id => base_member_id, :member_name => @member_base.name, :notice_error => '授权人信息添加失败,可能的原因是授权人姓名，身份证号或证件号有非法输入或已经被使用！'}
        else
          format.html { render :action => 'new'}
          format.xml { render :xml => @member.errors, :status => :unprocessable_entity }
        end       
      end
    end
  end

  # PUT /members/1
  # PUT /members/1.xml
  def update
    @member = Member.find(params[:id])
    is_member = params[:member][:is_member]
    respond_to do |format|
      if @member.update_attributes(params[:member])
        if CommonResource::IS_GRANTER.to_s.eql?(is_member)
          @member_base = Member.find(params[:member_id])
          format.html { redirect_to :action => "granter_index", :member_id => params[:member_id], :notice => '授权人信息修改成功！'}
        else
          format.html { redirect_to @member, :notice => '会员信息修改成功！' }
          format.xml  { head :ok }
        end
      else
        if CommonResource::IS_GRANTER.to_s.eql?(is_member)
          @member_base = Member.find(params[:member_id])
          format.html { render :action => "granter_edit" }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @member.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.xml
  def destroy
    @member = Member.find(params[:id])
    @member.status = 0#更新状态
    @member.save
    respond_to do |format|
      format.html { redirect_to(members_url) }
      format.xml  { head :ok }
    end
  end

  def granter_index
    @member = Member.find(params[:member_id])
    @notice = params[:notice]
    respond_to do |format|
      format.html
      format.xml  { render :xml => @member }
    end
  end

  def granter_new
    @member = Member.new
    @member_base = Member.find(params[:member_id])
    @member_card_id = params[:member_card_id]
    render :layout => false
  end

  def granter_edit
    @member = Member.find(params[:granter_id])
    @member_base = Member.find(params[:member_id])
    respond_to do |format|
      format.html
      format.xml  { head :ok }
    end
  end

  def granter_delete
    @mb = Member.find(params[:member_id])
    @member_granter = MemberCardGranter.where(:granter_id => params[:granter_id]).first
    @member_granter.destroy if !@member_granter.nil?

    @member = Member.find(params[:granter_id])
    @member.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'granter_index', :member_id => params[:member_id], :notice => '授权人删除成功！' }
      format.xml  { head :ok }
    end
  end

  def granter_show
    @granter = Member.find(params[:id])
    @base_member = Member.find(params[:member_id]) if !params[:member_id].nil?
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @member }
    end
  end

  #member_card
  def member_card_bind_index
    @member_name = params[:member_name]
    @member = Member.where(:name => params[:member_name]).first if !params[:member_name].nil?
    @notice = params[:notice]
    @notice_error = params[:notice_error]
    @cards = Card.where(:status => CommonResource::CARD_ON)
    @member_cards = MemberCard.where(:member_id => @member.id).where("status != ?", CommonResource::MEMBER_CARD_FREEZE) if !params[:member_name].nil?
  end

  def member_card_bind_list
    @member = Member.find(params[:member_id])
    @cards = Card.where(:status => CommonResource::CARD_ON)
    render :layout => false
  end

  def member_card_bind_update
    @member = Member.find(params[:member_id])
    @member_card = MemberCard.new(params[:member_card])
    @member_card.member_id = params[:member_id]
    @member_card.card_id = params[:binded_card_id]
    @member_card.user_id = current_user.id
    @member_card.password = @member.name
    notice = @member_card.save ? '会员卡绑定成功！' : @member_card.errors.full_messages.values.join(';')
    respond_to do |format|
      format.html { redirect_to :action => "member_card_bind_index",
        :member_name => @member.name, :member_id => params[:member_id], :notice => notice}
      format.xml  { head :ok }
    end
  end

  def member_card_index
    @member = Member.find(params[:member_id])
    @member_cards = MemberCard.where(:member_id => params[:member_id])
    render :layout => false
  end

  def member_card_recharge
    fee = (params[:fee].blank? ? 0 : params[:fee])
    times = (params[:times].blank? ? 0 : params[:times])

    member_card = MemberCard.find(params[:member_card_id])
    charge_fee = params[:type]=="1" ? fee.to_f : (-fee.to_f)
    charge_times = params[:type]=="1" ? times.to_f : (-times.to_f)

    if (member_card.update_attribute(:left_fee, member_card.left_fee.to_f + charge_fee) &&
        member_card.update_attribute(:left_times, member_card.left_times.to_f + charge_times))
        RechargeRecord.new(:member_id => member_card.member_id,
          :member_card_id => member_card.id,
          :recharge_fee => charge_fee#增加一个记录次数的字段或者换算
          ).save
        notice = params[:type]=="1" ? "会员卡充值成功！" : "会员卡退款成功！"
    end
   if !params[:expire_date].blank?
      member_card.update_attribute(:expire_date, params[:expire_date])
      notice = "有效期修改成功！"
   end
    render :inline => notice.to_json
  end

  def get_members
    @items = Member.where(["name = ?", "#{params[:name].downcase}"]).where(:status => CommonResource::MEMBER_STATUS_ON).limit(1)
    @ids = []
    @items.each { |i| @ids << i.id }
    render :inline => @ids.to_json
  end

  #没有用到了，后面要用来修改会员卡状态
  def member_card_freeze
    member = Member.find(params[:member_id])
    member_card = MemberCard.find(params[:member_card_id])
    if member_card.update_attribute(:status, params[:type])
      @notice = (params[:type]=="1" ? "会员卡已注销！" : "会员卡已恢复！")
    end
    redirect_to :action => "member_card_bind_index", :member_id => params[:member_id], :member_name => member.name, :notice => '操作成功！'
  end

  def getMemberCardNo
    cardNo = ""
    if !params[:card_id].blank?
      card = Card.find(params[:card_id])
      cardNo = card.card_prefix + member_card_num4(card)
    end
    render :inline => cardNo.to_json
  end


  private

  def get_granters
    @member_card_granters = MemberCardGranter.where(:member_id => params[:member_id])
    options = []
    @member_card_granters.each { |member_card_granter| options << member_card_granter.granter_id }
    @granters = Member.where(["id IN(?)", options]).where(:is_member => CommonResource::IS_GRANTER)
  end

  def member_card_num4(card)
      last_member_card = MemberCard.where(:card_id => card.id).order("card_serial_num desc").first#return nil if do not find

      if last_member_card.nil?
          num = "0001"
          n2 = ((num[-4, num.length].to_s).to_i).to_s
      else
         num = last_member_card.card_serial_num
         n2 = ((num[-4, num.length].to_s).to_i+1).to_s
      end

      if(n2.length == 1)
        n2=("000"+n2)
      end
      if(n2.length == 2)
        n2=("00"+n2)
      end
      if(n2.length == 3)
        n2=("0"+n2)
      end
      n2
  end
end