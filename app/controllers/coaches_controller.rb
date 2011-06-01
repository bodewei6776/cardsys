class CoachesController < ApplicationController

  layout 'main'

  # GET /coaches
  # GET /coaches.xml
  def index
    @coaches = Coach.paginate(default_paginate_options)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @coaches }
    end
  end

  # GET /coaches/1
  # GET /coaches/1.xml
  def show
    @coach = Coach.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @coach }
    end
  end

  # GET /coaches/new
  # GET /coaches/new.xml
  def new
    @coach = Coach.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @coach }
    end
  end

  # GET /coaches/1/edit
  def edit
    @coach = Coach.find(params[:id])
  end

  # POST /coaches
  # POST /coaches.xml
  def create
    @coach = Coach.new(params[:coach])
   # @coach.catena_id = session[:catena_id]    
    respond_to do |format|
      if @coach.save
#        source_pic = @coach.portrait
        format.html { redirect_to(@coach, :notice => '教练信息添加成功！') }
        format.xml  { render :xml => @coach, :status => :created, :location => @coach }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @coach.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /coaches/1
  # PUT /coaches/1.xml
  def update
    @coach = Coach.find(params[:id])
    respond_to do |format|
      @coach.telephone = params[:coach][:telephone]
      if @coach.update_attributes(params[:coach])
        format.html { redirect_to(@coach, :notice => '教练信息修改成功！') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @coach.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /coaches/1
  # DELETE /coaches/1.xml
  def destroy
    @coach = Coach.find(params[:id])
    @coach.destroy
    respond_to do |format|
      format.html { redirect_to(coaches_url) }
      format.xml  { head :ok }
    end
  end


  def change_status
    @coach = Coach.find(params[:id])
    @coach.update_attribute("status", params[:status])
    respond_to do |format|
      format.html { redirect_to(coaches_url) }
      format.xml  { head :ok }
    end
  end
end
