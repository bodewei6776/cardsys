class ReportsController < ApplicationController
  layout "main"
  def coach
  end

  def income
    @date = Date.parse(params[:date]) rescue  Date.today
    @pay_ways = params[:pay_ways] || [1,2,3,4,5,6,7]
  end

  def good_type_day
    @date = Date.parse(params[:date])
    @good_type =CommonResourceDetail.find(params[:id])
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
