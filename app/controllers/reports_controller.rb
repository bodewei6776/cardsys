# -*- encoding : utf-8 -*-
class ReportsController < ApplicationController
  def coach
  end

  def income
    @date = Date.parse(params[:date]) rescue  Date.today
    @pay_ways = params[:pay_ways] || ["card"] 
  end

  def income_by_month
    @date = Date.parse(params[:date] + "-1") rescue  Date.today.beginning_of_month
    @pay_ways = params[:pay_ways] || ["card"] 
  end

  def good_type_day
    @date = Date.parse(params[:date])
    @good_type = Category.find(params[:id])
    Balance.good_stat_per_date_by_type(@date,@good_type)
  end

  def print_good_type_day
    @date = Date.parse(params[:date])
    @good_type =CommonResourceDetail.find(params[:id])
    Balance.good_stat_per_date_by_type(@date,@good_type)
    render :layout => false
  end


  def good_search
    @order_items = OrderItem.scoped
    @order_items = @order_items.where({:item_type => "Good", :balanced => true})
    @order_items = @order_items.where("created_at > #{params[:start_time]}") if params[:start_time].present?
    @order_items = @order_items.where("created_at < #{params[:end_time]}") if params[:end_time].present?
    @order_items = @order_items.where("goods.name = '#{params[:name].strip}'").joins("join goods").where("goods.id = order_items.item_id") if params[:name].present?
    @order_items = @order_items.where("goods.good_type = #{params[:good_type]}").joins("join goods").where("goods.id = order_items.item_id") if params[:good_type].present?
    @order_items = @order_items.paginate default_paginate_options_without_created_at
  end


end
