# -*- encoding : utf-8 -*-
class LockersController < ApplicationController
  def index
    @date = Date.today
    @predate = Date.today - 1
    @nextdate = Date.today + 1
    @lockers = Locker.all
  end

  def list
    @lockers = Locker.all
  end


  def new
    @locker = Locker.new 
  end

  def create
    @locker = Locker.new params[:locker]
    if @locker.save
      flash[:notice] = "创建成功"
      redirect_to list_lockers_path
    else
      render :action => "new"
    end
  end

  def edit
    @locker = Locker.find  params[:id]
  end

  def update
    @locker = Locker.find  params[:id]
    if @locker.update_attributes params[:locker]
      flash[:notice] = "修改成功"
      redirect_to list_lockers_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @locker = Locker.find  params[:id]

    if @locker.destroy
      flash[:notice] = "删除成功"
    else
      flash[:notice] = "删除失败"
    end

    redirect_to list_lockers_path
  end
end
