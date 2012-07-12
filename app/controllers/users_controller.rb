# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  skip_before_filter :require_user

  def autocomplete_user_name
    @items = User.where(["user_name_pinyin like ? or login like ?", "%#{params[:term].downcase}%", "%#{params[:term].downcase}%"]).limit(10)
    @names = []
    @items.each { |i| @names << i.login}
    render :inline => @names.to_json#{lable:name, value:name}
  end


  
  def index
    @users = User.paginate(default_paginate_options)
  end

  def new
    @departments = Department.all
    @user = User.new
    @user.departments << @departments.try(:first) 
  end
  
  def create    
    @user = User.new(params[:user])
    @user.departments = Department.find(params[:dep])
    if @user.save
      redirect_to users_path, :notice => "用户添加成功"
    else     
      @departments = Department.all
      render :action => :new
    end
  end
  
  def show
   @user = User.find_by_id(params[:id]) || current_user
  end

  def edit
    @departments = Department.all
    @user = User.find(params[:id])
  end

  def update
    @user =User.find(params[:id]) 
    @user.departments = Department.find(params[:dep])
    if @user.update_attributes(params[:user])
      redirect_to users_path, :notice => "用户修改成功"
    else
      @departments = Department.all
      render :action => :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end


  def invalid_power_page
  end


  def change_password
  end

  def change_pass
    if params[:password].blank? or params[:new_password].blank? or params[:password_confirmation].blank?
      flash[:notice] = "不能为空呀"
      redirect_to change_password_users_path and return
    end
    unless current_user.valid_password?(params[:password])
      redirect_to change_password_users_path,:notice => "原来的密码错误" and return
    end

    unless params[:new_password] == params[:password_confirmation]

      redirect_to change_password_users_path,:notice => "两次密码输入需相同" and return
    end

    current_user.password = params[:new_password]
    current_user.password_confirmation = params[:new_password]
    if current_user.save
      flash[:notice] = "密码修改成功"
    else
      flash[:notice] = "密码修改失败"
    end
    redirect_to change_password_users_path
  end


  def switch_state
    @user = User.find(params[:id])
    @user.switch_state!
    redirect_to(users_path) 
  end
end
