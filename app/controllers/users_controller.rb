class UsersController < ApplicationController
  
  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => [:show, :edit, :update]
  #layout false, :only => [:create, :new]
  skip_before_filter :require_user,:require_very_user

  before_filter :user_can
  
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end
  
  def create    
    @user = User.new(params[:user])
    if @user.save
      dp = DepartmentUser.new(:user_id => @user.id, :department_id => params[:department_id])
      dp.save
      flash[:notice] = "用户注册成功！"
      redirect_back_or_default "/user_sessions/new" #modify by lixj
    else     
      render :action => :new
    end
  end
  
  def show
   @user = @current_user
    redirect_to members_url#先跳转到这里  lixj
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "用户信息修改成功！"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  # DELETE /courts/1
  # DELETE /courts/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def user_power_index
    @user = User.find(params[:id])
    #本部门的所有权限
    department ||= 1
    if @user.department 
      department = @user.department
    end
    power_ids = DepartmentPower.where(:department_id => department).each { |i| i.power }
    @powers = Power.where(["id in (?)", power_ids])
    @notice = params[:notice]
  end

  def user_power_update
    UserPower.delete_all("user_id = #{params[:user_id]}")
    for power in Power.all
      #被选中可用的
      if params["user_power_#{power.id}"]
        UserPower.create(:user_id => params[:user_id],
          :power_id =>  power.id,
          :catena_id =>  session[:catena_id])
      end
    end
    respond_to do |format|
      format.html { redirect_to :action => "user_power_index", :id => params[:user_id], :notice => '用户权限设置成功！'}
      format.xml  { head :ok }
    end
  end
  
  def invalid_power_page
  end

  def user_can
#    if !current_user.can?(self.action_name, "user")
#       redirect_to :action => "invalid_power_page"
#    end
    true
  end

end
