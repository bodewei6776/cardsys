class CommonResourcesController < ApplicationController
  before_filter :super_admin_required

  def super_admin_required
    redirect_to about_path and return unless current_user.login == "admin"
  end

  def index
    @common_resources = CommonResource.all
  end

  def show
    @common_resource = CommonResource.find(params[:id])
    str = ""
    @common_resource.common_resource_details.each { |e| str += e.detail_name }
    @common_resource.detail_str = str
  end

  def new
    @common_resource = CommonResource.new
  end

  def edit
    @common_resource = CommonResource.find(params[:id])
  end

  def create
    @common_resource = CommonResource.new(params[:common_resource])

    if @common_resource.save        
      redirect_to(@common_resource, :notice => '公共资源添加成功.') 
    else
      render :action => "new" 
    end
  end

  def update
    @common_resource = CommonResource.find(params[:id])

    if @common_resource.update_attributes(params[:common_resource])
      redirect_to(@common_resource, :notice => '公共资源修改成功.') 
    else
      render :action => "edit" 
    end
  end

  def destroy
    @common_resource = CommonResource.find(params[:id])
    @common_resource.destroy

    redirect_to common_resources_url
  end

  def common_resource_detail_index
    @common_resource = CommonResource.find(params[:common_resource_id])
    @common_resource_details = CommonResourceDetail.where(:common_resource_id => params[:common_resource_id])     
  end

  def edit_detail
    @common_resource = CommonResource.find(params[:id])
    @common_resource_detail = CommonResourceDetail.find(params[:detail_id]) if !params[:detail_id].nil?
    render :layout => false
  end

  def delete_detail    
    CommonResourceDetail.destroy(params[:detail_id])
    redirect_to :action => "common_resource_detail_index", :common_resource_id => params[:common_resource_id] 
  end

  def update_detail
    if params[:type] == "0"
      CommonResourceDetail.new(
        :common_resource_id => params[:common_resource_id],               
        :detail_name => params[:detail_name]
      ).save
    else
      CommonResourceDetail.find(params[:detail_id]).update_attribute("detail_name", params[:detail_name])
    end
    render :inline => "资源信息更新成功！".to_json
  end


  def power_index
  end

  def power_update
    if  params[:password] != "lijiyang"  
      flash[:notice] = "用户名密码不正确"
      render :action => "power_index"
      return
    end

    powers = Power.find(params[:powers])
    if powers.present?
      Power.all_with_hide.each do |p|
        p.will_show = params[:powers].include?(p.id.to_s)
        p.save
      end
      flash[:notice] = " 更新成功"
    end
    redirect_to power_index_common_resources_path
  end
end
