class DepartmentsController < ApplicationController
  before_filter :load_department, :only => [:show, :edit, :update, :destroy, :department_power_index, :department_power_update]
  def index
    @departments = Department.all
  end

  def show
  end

  def new
    @department = Department.new
  end

  def edit
  end

  def create
    @department = Department.new(params[:department])

    if @department.save
      redirect_to(:action => "index", :notice => '部门信息创建成功！') 
    else
      render :action => "new" 
    end
  end

  def update
    if @department.update_attributes(params[:department])
      redirect_to(departments_url, :notice => '部门信息修改成功！')
    else
      render :action => "edit" 
    end
  end

  def destroy
    @department.destroy
    redirect_to departments_url
  end

  def department_power_index
    @powers = Power.all
    @notice = params[:notice]
  end

  def department_power_update
    @department.powers = Power.find(params[:powers])
    @department.save
    redirect_to :action => "department_power_index", :id =>@department.id, :notice => '部门权限设置成功！'
  end
end
