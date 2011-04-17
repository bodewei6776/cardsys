class VacationsController < ApplicationController

  layout 'main'

  # GET /vacations
  # GET /vacations.xml
  def index
    @vacations = Vacation.paginate(default_paginate_options)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @vacations }
    end
  end

  # GET /vacations/1
  # GET /vacations/1.xml
  def show
    @vacation = Vacation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @vacation }
    end
  end

  # GET /vacations/new
  # GET /vacations/new.xml
  def new
    @vacation = Vacation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @vacation }
    end
  end

  # GET /vacations/1/edit
  def edit
    @vacation = Vacation.find(params[:id])
  end

  # POST /vacations
  # POST /vacations.xml
  def create
    @vacation = Vacation.new(params[:vacation])

    respond_to do |format|
      if @vacation.save
        format.html { redirect_to(:action => "index", :notice => '节假日创建成功！') }
        format.xml  { render :xml => @vacation, :status => :created, :location => @vacation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @vacation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /vacations/1
  # PUT /vacations/1.xml
  def update
    @vacation = Vacation.find(params[:id])

    respond_to do |format|
      if @vacation.update_attributes(params[:vacation])
        format.html { redirect_to(vacations_url, :notice => '节假日修改成功！')}
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @vacation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /vacations/1
  # DELETE /vacations/1.xml
  def destroy
    @vacation = Vacation.find(params[:id])
    @vacation.destroy

    respond_to do |format|
      format.html { redirect_to(vacations_url) }
      format.xml  { head :ok }
    end
  end
end
