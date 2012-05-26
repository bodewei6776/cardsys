# -*- encoding : utf-8 -*-
class CommonResourceDetailsController < ApplicationController
  before_filter :find_common_resource, :only => [:new, :edit, :index, :create]

  def new
    @common_resource_detail = @common_resource.common_resource_details.build
  end

  def edit
    @common_resource_detail = CommonResourceDetail.find params[:id]
    @common_resource = @common_resource_detail.common_resource
  end

  def create
    @common_resource_detail = @common_resource.common_resource_details.build(params[:common_resource_detail])
    if @common_resource_detail.save
      redirect_to common_resource_common_resource_details_path(@common_resource)
    else
      render :action => "new"
    end
  end

  def update
    @common_resource_detail = CommonResourceDetail.find params[:id]
    if @common_resource_detail.update_attributes params[:common_resource_detail]
      redirect_to common_resource_common_resource_details_path(@common_resource)
    else
      render :action => "edit"
    end
  end


  def destroy
    CommonResourceDetail.find( params[:id]).destroy
    redirect_to common_resource_common_resource_details_path(@common_resource)
  end

  def index
    @common_resource_details = @common_resource.common_resource_details
  end

  def find_common_resource
    @common_resource = CommonResource.find_by_id(params[:common_resource_id] || -1)
  end

end
