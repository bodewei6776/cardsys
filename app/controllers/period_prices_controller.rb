# -*- encoding : utf-8 -*-
class PeriodPricesController < ApplicationController
  before_filter :load_period_price, :only => [ :show, :edit, :update, :destroy]

  def index
    @date_type = CommonResource.date_type Date.today
    @period_prices = PeriodPrice.paginate(default_paginate_options)
  end

  def show
  end

  def new
    @period_price = PeriodPrice.new
  end

  def edit
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
    if @period_price.update_attributes(params[:period_price])
      redirect_to @period_price, :notice => '时段价格修改成功！' 
    else
      render :action => "edit" 
    end
  end

  def destroy
    begin
      @period_price.destroy
    rescue Exception => e
      flash[:error] = '不能删除此时间段！'
    end
    redirect_to(period_prices_url) 
  end

  def load_period_price
    @period_price = PeriodPrice.find(params[:id])
  end

end
