# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8ec6935fe52d16c7a633b948c07815f1'
  helper_method :current_catena,:cart

  layout  "index"

  before_filter :configure_charsets ,:set_date
  before_filter :require_user#,:require_very_user #应该过滤掉登陆用户

  helper_method :current_user_session, :current_user
  before_filter :set_catena

  def set_catena
    Catena.current=(Catena.find_by_id(session[:catena_id]) || current_user.catena || Catena.default_catena) if current_user
  end

  def current_catena
    Thread.current[:catena]
  end

  def current_catena_id
    Thread.current[:catena_id]
  end

  self.allow_forgery_protection = false

  def render_js(script)
    render :js => "<script type='text/javascript'>" + script + "</script>"
  end

  protected

  def set_date
    @date ||= DateTime.now
  end

  def configure_charsets
    request.headers["Content-Type"] = "text/html;charset=utf-8 "
  end

  def authorize
    unless User.find_by_id(session[:user_id])
      flash[:notice] = "请登陆！"
      redirect_to(:controller => "login", :action => "signup")
    end
  end
  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)    
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = (current_user_session && current_user_session.user)
  end

  def require_very_user
    if current_user.nil? || !current_user.can?(action_name,controller_name.singularize)
      store_location
      flash[:notice] = I18n.t("session_user.require_login")
      redirect_to new_user_session_url
      return false
    end
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = I18n.t("session_user.require_login")
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = I18n.t("session_user.require_login")
      redirect_to account_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def default_paginate_options
    {:page => params[:page] || 1,:per_page => 20,:order => "created_at DESC"}
  end
  def default_paginate_options_without_created_at
    {:page => params[:page] || 1,:per_page => 20}
  end



  def cart
    session[:cart] || Cart.new
  end
end

