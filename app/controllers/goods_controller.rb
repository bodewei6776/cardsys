class GoodsController < ApplicationController

  def autocomplete_name
    @goods = Good.where(["pinyin_abbr like ? or name like ?", "%#{params[:term]}%", "%#{params[:term]}%"]).where(:status => CommonResource::GOOD_ON).limit(10)
    @goods.each { |g| @names = [] << g.name }
    render :inline => @names.to_json
  end

  # GET /goods
  # GET /goods.xml
  def index
    @p = params[:p]
    @good_type = params[:good_type]
    @name = params[:name]
    @goods = Good.order("id desc")
    @goods = @goods.where(["good_type = ? ", @good_type]) if !params[:good_type].blank?
    @goods = @goods..where(["name = ? ", @name]) if !params[:name].blank?
    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "/goods/goods", :locals => { :goods => @goods }
        else
          render :template =>  '/goods/index'
        end
        }
      format.xml  { render :xml => @goods }
    end
  end

  # GET /goods/1
  # GET /goods/1.xml
  def show
    @good = Good.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @good }
    end
  end

  # GET /goods/new
  # GET /goods/new.xml
  def new
    @good = Good.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @good }
    end
  end

  # GET /goods/1/edit
  def edit
    @good = Good.find(params[:id])
  end

  # POST /goods
  # POST /goods.xml
  def create
    @good = Good.new(params[:good])
    @good.count_total_now = @good.count_back_stock
    @good.count_front_stock = 0
    respond_to do |format|
      if @good.save
        format.html { redirect_to(@good, :notice => '商品信息添加成功！') }
        format.xml  { render :xml => @good, :status => :created, :location => @good }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @good.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /goods/1
  # PUT /goods/1.xml
  def update
    @good = Good.find(params[:id])

    respond_to do |format|
      if @good.update_attributes(params[:good])
        format.html { redirect_to(@good, :notice => '商品信息修改成功！') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @good.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /goods/1
  # DELETE /goods/1.xml
  def destroy
    @good = Good.find(params[:id])
    @good.destroy

    respond_to do |format|
      format.html { redirect_to(goods_url) }
      format.xml  { head :ok }
    end
  end

  def store_manage_index
    @p = params[:p]
    @good = Good.find(params[:id])
    render :layout => false
  end

  def store_manage_update
    @good = Good.find(params[:id])
    @p = params[:p]
    count_back_stock_out = params[:good][:count_back_stock_out].to_i
    count_back_stock_in  = params[:good][:count_back_stock_in].to_i
    count_front_stock_in = params[:good][:count_front_stock_in].to_i
    @good.count_back_stock  += (count_back_stock_in - count_back_stock_out - count_front_stock_in )
    @good.count_front_stock += count_front_stock_in
    @good.count_total_now   = @good.count_back_stock + @good.count_front_stock
    msg = @good.save ? 'yes' : 'no'
    render :text => msg
  end

  def change_status
    @good = Good.find(params[:id])
    @good.update_attribute("status", params[:status])
    respond_to do |format|
      format.html { redirect_to(goods_url) }
      format.xml  { head :ok }
    end
  end
  
  def goods
    if params[:id].to_i > 0
      @goods = [Good.find(params[:id])]
    else
      @goods = Good.order('sale_count desc').limit(30)
    end
    render :layout => false
  end
  
  def to_buy
    @goods = Good.order('sale_count desc').limit(30)
    render :action => 'goods'
  end
  
  def add_to_cart
    goods = []
    (params[:goods]||[]).map{|hash_good|
      next if  hash_good[:count].to_i <= 0
       good = Good.find(hash_good[:id])
       good.order_count = hash_good[:count].to_i
       goods << good
     }
     order = Order.find(params[:order_id])
     unless (good_items = order.order_goods(goods)).blank?
        render :partial => "/orders/order_item", :locals => {:good_items => good_items,:order => order}
     else
        render :text => "<span class='error' style='color:red'>#{order.errors.full_messages.join('<br/>')}</span>"
     end
  end

end