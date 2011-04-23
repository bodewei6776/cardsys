class CommonResourcesController < ApplicationController
  # GET /common_resources
  # GET /common_resources.xml
  layout "main"
  before_filter :super_admin_required

  def super_admin_required
    redirect_to about_path and return unless current_user.login == "admin"
  end

  def index
    @common_resources = CommonResource.all
    
#    @common_resources.each { |item|
#      str =""
#      item.common_resource_details.each{ |e| str += (e.nil? ? "" : e.detail_name)}
#      item.detail_str = str }
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @common_resources }
    end
  end

  # GET /common_resources/1
  # GET /common_resources/1.xml
  def show
    @common_resource = CommonResource.find(params[:id])
    str = ""
    @common_resource.common_resource_details.each { |e| str += e.detail_name }
    @common_resource.detail_str = str
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @common_resource }
    end
  end

  # GET /common_resources/new
  # GET /common_resources/new.xml
  def new
    @common_resource = CommonResource.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @common_resource }
    end
  end

  # GET /common_resources/1/edit
  def edit
    @common_resource = CommonResource.find(params[:id])
  end

  # POST /common_resources
  # POST /common_resources.xml
  def create
    @common_resource = CommonResource.new(params[:common_resource])

    respond_to do |format|
      if @common_resource.save        
        format.html { redirect_to(@common_resource, :notice => '公共资源添加成功.') }
        format.xml  { render :xml => @common_resource, :status => :created, :location => @common_resource }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @common_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /common_resources/1
  # PUT /common_resources/1.xml
  def update
    @common_resource = CommonResource.find(params[:id])

    respond_to do |format|
      if @common_resource.update_attributes(params[:common_resource])
        format.html { redirect_to(@common_resource, :notice => '公共资源修改成功.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @common_resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /common_resources/1
  # DELETE /common_resources/1.xml
  def destroy
    @common_resource = CommonResource.find(params[:id])
    @common_resource.destroy

    respond_to do |format|
      format.html { redirect_to(common_resources_url) }
      format.xml  { head :ok }
    end
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
    respond_to do |format|
      format.html { redirect_to :action => "common_resource_detail_index", :common_resource_id => params[:common_resource_id] }
      format.xml  { head :ok }
    end
  end

  def update_detail
#    @common_resource = CommonResource.find(params[:common_resource_id])
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
