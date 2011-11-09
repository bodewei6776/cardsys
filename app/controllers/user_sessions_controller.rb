class UserSessionsController < ApplicationController
  skip_before_filter :require_user

  def new
    @user_session = UserSession.new

    render :layout => false
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      redirect_back_or_default root_path 
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "退出系统!"
    redirect_to new_user_session_url
  end
end

