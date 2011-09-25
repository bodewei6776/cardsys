class UserSessionsController < ApplicationController
  layout false
  skip_before_filter :require_user,:require_very_user 

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      @catena = Catena.find(params[:catena_id]) rescue Catena.first
      unless @user_session.user.catenas.include? @catena
        @user_session.destroy
        render :action => "new" and return
      else
        session[:catena_id] = @catena.id
        Catena.current = @catena
      end
      redirect_back_or_default root_path 
    else
      render :action => :new
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "退出系统!"
    redirect_back_or_default new_user_session_url
  end
end

