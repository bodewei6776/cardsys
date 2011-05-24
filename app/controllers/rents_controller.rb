class RentsController < ApplicationController
  layout 'main'
  # GET /rents
  # GET /rents.xml
  def index
    @rents = Rent.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rents }
    end
  end

  # GET /rents/1
  # GET /rents/1.xml
  def show
    @rent = Rent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rent }
    end
  end

  # GET /rents/new
  # GET /rents/new.xml
  def new
    @rent = Rent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rent }
    end
  end

  # GET /rents/1/edit
  def edit
    @rent = Rent.find(params[:id])
  end

  # POST /rents
  # POST /rents.xml
  def create
    @rent = Rent.new(params[:rent])

    respond_to do |format|
      if @rent.save
        format.html { redirect_to(@rent, :notice => 'Rent was successfully created.') }
        format.xml  { render :xml => @rent, :status => :created, :location => @rent }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rents/1
  # PUT /rents/1.xml
  def update
    @rent = Rent.find(params[:id])

    respond_to do |format|
      if @rent.update_attributes(params[:rent])
        format.html { redirect_to(@rent, :notice => 'Rent was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rents/1
  # DELETE /rents/1.xml
  def destroy
    @rent = Rent.find(params[:id])
    @rent.destroy

    respond_to do |format|
      format.html { redirect_to(rents_url) }
      format.xml  { head :ok }
    end
  end
end
