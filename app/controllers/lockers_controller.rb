class LockersController < ApplicationController
  layout 'main'
  # GET /lockers
  # GET /lockers.xml
  #
  #

  def autocomplete_num
    @lockers= Locker.where(["num like ?", "%#{params[:term]}%",]).limit(10)
    @num= @lockers.collect(&:num) rescue []
    render :inline => @num.to_json
  end

  def list 
    @lockers = Locker.where("1=1")
    if params[:locker_type].presence
      @locker_type = params[:locker_type]
      @lockers = @lockers.where(:locker_type => @locker_type)
    end

    if params[:num].presence
      @num = params[:num]
      @lockers = @lockers.where(["num like ?","%#{@num}%"])
    end

    @lockers = @lockers.paginate(default_paginate_options)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lockers }
    end
  end


  def index
    @lockers = Locker.rented.paginate(default_paginate_options)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lockers }
    end
  end

  # GET /lockers/1
  # GET /lockers/1.xml
  def show
    @locker = Locker.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @locker }
    end
  end

  # GET /lockers/new
  # GET /lockers/new.xml
  def new
    @locker = Locker.new
    @locker.num = Locker.next_num

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @locker }
    end
  end

  # GET /lockers/1/edit
  def edit
    @locker = Locker.find(params[:id])
  end

  # POST /lockers
  # POST /lockers.xml
  def create
    @locker = Locker.new(params[:locker])

    respond_to do |format|
      if @locker.save
        format.html { redirect_to(list_lockers_path, :notice => 'Locker was successfully created.') }
        format.xml  { render :xml => @locker, :status => :created, :location => @locker }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @locker.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lockers/1
  # PUT /lockers/1.xml
  def update
    @locker = Locker.find(params[:id])

    respond_to do |format|
      if @locker.update_attributes(params[:locker])
        format.html { redirect_to(@locker, :notice => 'Locker was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @locker.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /lockers/1
  # DELETE /lockers/1.xml
  def destroy
    @locker = Locker.find(params[:id])
    @locker.destroy

    respond_to do |format|
      format.html { redirect_to(list_lockers_path) }
      format.xml  { head :ok }
    end
  end
end
