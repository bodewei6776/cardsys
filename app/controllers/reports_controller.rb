class ReportsController < ApplicationController
  layout "main"
  def coach
  end

  def income
    @date = Date.parse(params[:date]) rescue  Date.today
    @select_way = params[:select_way] || "1"
    @pay_ways = params[:pay_ways] || [] 
  end

  def income_by_month
    @date = Date.parse(params[:date] + "-1") rescue  Date.today.beginning_of_month
    @select_way = params[:select_way] || "1"
    @pay_ways = params[:pay_ways] || [] 
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

  def member_cosume_detail
  end

  def court_usage
  end

end
