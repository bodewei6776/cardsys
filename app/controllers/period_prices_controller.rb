class PeriodPricesController < ApplicationController

  layout 'main'
  
  # GET /card_templates
  # GET /card_templates.xml
  def index
    @period_prices = PeriodPrice.paginate(default_paginate_options)
    respond_to do |format|
      format.html
      format.xml { render :xml => @period_prices}
    end
  end

  # GET /card_templates/1
  # GET /card_templates/1.xml
  def show
    @period_price = PeriodPrice.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @period_price }
    end
  end

  # GET /card_templates/new
  # GET /card_templates/new.xml
  def new
    @period_price = PeriodPrice.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @period_price }
    end
  end

  # GET /card_templates/1/edit
  def edit
    @period_price = PeriodPrice.find(params[:id])
  end

  # POST /periodPrices
  # POST /periodPrices.xml
  def create
    @period_price = PeriodPrice.new(params[:period_price])
    respond_to do |format|
      if @period_price.save
          #给场地设置默认的时段
          Court.all.each { |court|
           cpp = CourtPeriodPrice.new(:period_price_id => @period_price.id,
            :court_price =>  @period_price.price,
            :court_id => court.id,
            :catena_id =>  session[:catena_id])
            cpp.save
          }
          @period_prices = PeriodPrice.all
          format.html {redirect_to :action => 'index', :notice => '时段价格创建成功！'}
          format.xml  { render :xml => @period_price }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @period_price.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /periodPrices/1
  # PUT /periodPrices/1.xml
  def update
    @period_price = PeriodPrice.find(params[:id])
    respond_to do |format|
      if @period_price.update_attributes(params[:period_price])
        format.html { redirect_to @period_price, :notice => '时段价格修改成功！' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @period_price.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /periodPrices/1
  # DELETE /periodPrices/1.xml
  def destroy
    @period_price = PeriodPrice.find(params[:id])
    begin
      @period_price.destroy
    rescue Exception => e
      flash[:error] = '不能删除此时间段！'
    end
    respond_to do |format|
      format.html { redirect_to(period_prices_url) }
      format.xml  { head :ok }
    end
  end

end
