# -*- encoding : utf-8 -*-
class CatenasController < ApplicationController
  def index
    @catenas = Catena.all
  end

  def show
    @catena = Catena.find(params[:id])

    respond_to do |format|
      format.xml  { render :xml => @catena }
    end
  end

  def new
    @catena = Catena.new

    respond_to do |format|
      format.xml  { render :xml => @catena }
    end
  end

  def edit
    @catena = Catena.find(params[:id])
  end

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
