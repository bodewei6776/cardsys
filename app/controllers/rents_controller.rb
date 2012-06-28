# -*- encoding : utf-8 -*-
class RentsController < ApplicationController
  def index
    @rents = Rent.paginate default_paginate_options
  end

  def new
    @locker = Locker.find params[:locker_id]
    @rent = @locker.rents.build
    @rent.is_member = true
    render :layout => "small_main"
  end

  def create
   @rent = Rent.new  params[:rent]
   @locker = @rent.locker
   if @rent.save
     flash[:notice] = "预订成功"
     render :layout => "small_main"
   else
     render :action => "new", :layout => "small_main"
   end
  end

  def update
    @rent = Rent.find params[:id]
    @locker = @rent.locker
    if params[:commit] == "退租"
      params[:rent][:end_date] = Date.today
      params[:rent][:total_fee] = @rent.total_fee
      params[:rent][:rent_state] = "disable"

      if @rent.update_attributes params[:rent]
        flash[:notice] = "#{params[:commit]}成功"
        redirect_to edit_locker_rent_path(@rent.locker, @rent)
      else
        flash[:notice] = "#{params[:commit]}失败"
        render :action => "edit", :layout => "small_main"
      end
    else
      @old_rent = Rent.find params[:id]
      @rent = Rent.new  params[:rent]
      @locker = @rent.locker
      if @rent.save
        flash[:notice] = "续订成功"
        render :action => "create", :layout => "small_main"
      else
        render :action => "new", :layout => "small_main"
      end
    end

  end

  def edit
    @rent = Rent.find params[:id]
    @locker = @rent.locker
    render :layout => "small_main"
  end
end
