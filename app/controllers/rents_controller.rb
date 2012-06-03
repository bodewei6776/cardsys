# -*- encoding : utf-8 -*-
class RentsController < ApplicationController
  def index
    @rents = Rent.all
  end

  def new
    @locker = Locker.find params[:locker_id]
    @rent = @locker.rents.build
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

  def edit
    @rent = Rent.find params[:id]
    @locker = @rent.locker
    render :layout => "small_main"
  end
end
