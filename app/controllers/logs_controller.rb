class LogsController < ApplicationController
  layout 'main'
  def index
    @logs = Log.where("1=1")
    @logs = @logs.where({:log_type => params[:t]}) if params[:t].present?
    if params[:start].present? && params[:end].present?
      @logs = @logs.where(["date_format(created_at,'%Y-%m-%d') < ? and date_format(created_at,'%Y-%m-%d') > ?",
                          params[:end],params[:start]])
    elsif  params[:start].present? || params[:end].present?
      @logs = @logs.where(["date_format(created_at,'%Y-%m-%d') = ?",params[:start].presence || params[:end].presence])
    end

    @logs = @logs.where({:user_name => params[:user] }) if params[:user].presence
    @logs = @logs.paginate(default_paginate_options)
  end
end
