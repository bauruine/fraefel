class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user
  before_filter :require_user, :user_setup
  # before_filter { |c| Authorization.current_user = c.current_user }
  
  private
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def require_user
    unless current_user
      store_location
      redirect_to login_url
      return false
    end
  end
  
  def store_location
    session[:return_to] = request.url
  end
  
  def user_setup
    # Find the current user
    User.current = current_user
    Authorization.current_user = current_user
  end
  
  def render_403
    respond_to do |format|
      format.html { render :template => "shared/403", :layout => (request.xhr? ? false : 'application'), :status => 403 }
    end
    return false
  end
  
  protected
  
  def permission_denied
    render_403
  end
end
