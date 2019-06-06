class ApplicationController < ActionController::Base
  helper_method :current_user
  helper_method :band

  def band
    @band ||= Band.find(params[:id])
  end

  def current_user
    # If @current_user does not exist, check the user by session_token
    @current_user ||= User.find_by(session_token: session[:session_token])
  end

  def logged_in?
    # if current_user do exist, this will return true
    !!current_user
  end

  def log_in_user!(user)
    session[:session_token] = user.reset_session_token!
  end
end
