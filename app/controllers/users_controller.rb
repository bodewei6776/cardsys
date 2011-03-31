class UsersController < ApplicationController
  layout 'main'
  
  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => [:show, :edit, :update]
  #layout false, :only => [:create, :new]
  skip_before_filter :require_user,:require_very_user

  before_filter :user_can
  
  def index
    @users = User.paginate(:page => params[:page]||1,:per_page => 20)
  end

  def new
    @departments = Department.all
    @user = User.new
    @user.departments << @departments.first
  end
  
  def create    
    @user = User.new(params[:user])
    @user.departments = Department.find(params[:dep])
    if @user.save
      flash[:notice] = "用户注册成功！"
      redirect_to users_path
      #redirect_back_or_default "/user_sessions/new" #modify by lixj
    else     
      @departments = Department.all
      render :action => :new
    end
  end
  
  def show
   @user = @current_user
    redirect_to members_url#先跳转到这里  lixj
  end

  def edit
  @departments = Department.all
    @user = User.find(params[:id])
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    @user.departments = @user.departments | Department.find(params[:dep])
    if @user.update_attributes(params[:user])
      flash[:notice] = "用户信息修改成功！"
      redirect_to account_url
    else
      @departments = Department.all
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
    @powers = Power.all
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
