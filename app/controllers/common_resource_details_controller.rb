class CommonResourceDetailsController < ApplicationController
  def new
  end

  def edit
  end

  def index
    CommonResource.find(params[:common_resource_id]).common_resource_details
  end

end
