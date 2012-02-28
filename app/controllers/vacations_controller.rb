# -*- encoding : utf-8 -*-
class VacationsController < ApplicationController


  def index
    @vacations = Vacation.paginate(default_paginate_options)
  end

  def show
    @vacation = Vacation.find(params[:id])
  end

  def new
    @vacation = Vacation.new
  end

  def edit
    @vacation = Vacation.find(params[:id])
  end

  def create
    @vacation = Vacation.new(params[:vacation])

    if @vacation.save
      redirect_to :action => "index", :notice => '节假日创建成功！'
    else
      render :action => "new" 
    end
  end

  def update
    @vacation = Vacation.find(params[:id])

    respond_to do |format|
      if @vacation.update_attributes(params[:vacation])
        redirect_to(vacations_url, :notice => '节假日修改成功！')
      else
        render :action => "edit" 
      end
    end
  end

  def destroy
    @vacation = Vacation.find(params[:id])
    @vacation.destroy
    redirect_to(vacations_url) 
  end
end
