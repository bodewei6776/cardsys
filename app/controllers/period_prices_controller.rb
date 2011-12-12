class PeriodPricesController < ApplicationController
  before_filter :load_period_price, :only => [ :show, :edit, :update, :destroy]

  def index
    @period_prices = PeriodPrice.paginate(default_paginate_options)
  end

  def show
    @period_price = PeriodPrice.find(params[:id])
  end

  def new
    @period_price = PeriodPrice.new
  end

  def edit
    @period_price = PeriodPrice.find(params[:id])
  end

  def create
    @period_price = PeriodPrice.new(params[:period_price])
    if @period_price.save
      Court.all.each { |court|
        CourtPeriodPrice.create(:period_price_id => @period_price.id,
                                   :court_price =>  @period_price.price,
                                   :court_id => court.id)
      }
      @period_prices = PeriodPrice.all
      redirect_to :action => 'index', :notice => '时段价格创建成功！'
    else
      render :action => "new" 
    end
  end

  def update
    @period_price = PeriodPrice.find(params[:id])
      if @period_price.update_attributes(params[:period_price])
        format.html { redirect_to @period_price, :notice => '时段价格修改成功！' }
      else
        format.html { render :action => "edit" }
      end
  end

  def destroy
    @period_price = PeriodPrice.find(params[:id])
    begin
      @period_price.destroy
    rescue Exception => e
      flash[:error] = '不能删除此时间段！'
    end
    redirect_to(period_prices_url) 
  end

end
