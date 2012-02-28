# -*- encoding : utf-8 -*-
class CoachesController < ApplicationController

  def index
    @coaches = Coach.paginate(default_paginate_options)
    respond_to do |wants|
      wants.html {}
      wants.json { render :json => @coaches.to_json(:only => [:id, :name])}
    end
  end

  def search
    @coaches = Coach.paginate(default_paginate_options.merge(:conditions => "lower(pinyin_name) like '%#{params[:q]}%'"))
    respond_to do |wants|
      wants.json { render :json => @coaches.collect{|c| {"name" => c.name, "id" => c.id, "pinyin_name" => c.pinyin_name}}.to_json}
    end
  end

  def show
    @coach = Coach.find(params[:id])
  end

  def new
    @coach = Coach.new
  end

  def edit
    @coach = Coach.find(params[:id])
  end

  def create
    @coach = Coach.new(params[:coach])
    if @coach.save
      redirect_to(@coach, :notice => '教练信息添加成功！') 
    else
      render :action => "new" 
    end
  end

  def update
    @coach = Coach.find(params[:id])
    @coach.telephone = params[:coach][:telephone]
    if @coach.update_attributes(params[:coach])
      redirect_to(@coach, :notice => '教练信息修改成功！') 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @coach = Coach.find(params[:id])
    @coach.destroy
    redirect_to(coaches_url) 
  end


  def change_status
    @coach = Coach.find(params[:id])
    @coach.update_attribute("status", params[:status])
    redirect_to(coaches_url) 
  end
end
