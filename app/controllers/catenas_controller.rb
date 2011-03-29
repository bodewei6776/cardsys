class CatenasController < ApplicationController
  # GET /catenas
  # GET /catenas.xml
  layout 'main'
  def index
    @catenas = Catena.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @catenas }
    end
  end

  # GET /catenas/1
  # GET /catenas/1.xml
  def show
    @catena = Catena.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @catena }
    end
  end

  # GET /catenas/new
  # GET /catenas/new.xml
  def new
    @catena = Catena.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @catena }
    end
  end

  # GET /catenas/1/edit
  def edit
    @catena = Catena.find(params[:id])
  end

  # POST /catenas
  # POST /catenas.xml
  def create
    @catena = Catena.new(params[:catena])

    respond_to do |format|
      if @catena.save
        format.html { redirect_to(catenas_path, :notice => 'Catena was successfully created.') }
        format.xml  { render :xml => @catena, :status => :created, :location => @catena }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @catena.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /catenas/1
  # PUT /catenas/1.xml
  def update
    @catena = Catena.find(params[:id])

    respond_to do |format|
      if @catena.update_attributes(params[:catena])
        format.html { redirect_to(@catena, :notice => 'Catena was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @catena.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /catenas/1
  # DELETE /catenas/1.xml
  def destroy
    @catena = Catena.find(params[:id])
    @catena.destroy

    respond_to do |format|
      format.html { redirect_to(catenas_url) }
      format.xml  { head :ok }
    end
  end
end

 def change_status
     @catena = Catena.find(params[:id])
     @catena.update_attribute("status", params[:status])
    respond_to do |format|
      format.html { redirect_to(catenas_url) }
      format.xml  { head :ok }
    end
  end
