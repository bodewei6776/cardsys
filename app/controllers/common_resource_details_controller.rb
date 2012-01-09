class CommonResourceDetailsController < ApplicationController
  before_filter :find_common_resource, :only => [:new, :edit, :index, :create, :destroy]

  def new
    @common_resource_detail = @common_resource.common_resource_details.build
  end

  def edit
  end

  def create
    @common_resource_detail = @common_resource.common_resource_details.build(params[:common_resource_detail])
    if @common_resource_detail.save
      redirect_to common_resource_common_resource_details_path(@common_resource)
    else
      render :action => "new"
    end
  end

  def destroy
    @common_resource.common_resource_details.find( params[:id]).destroy
    redirect_to common_resource_common_resource_details_path(@common_resource)
  end

  def index
    @common_resource_details = @common_resource.common_resource_details
  end

  def find_common_resource
    @common_resource = CommonResource.find  params[:common_resource_id]
  end

end
