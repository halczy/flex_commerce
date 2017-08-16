class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def authenticate_user
    unless helpers.signed_in?
      flash[:warning] = "You must log in to perform this action."
      helpers.store_location
      redirect_to signin_path
    end
  end

  def authenticate_admin
    unless helpers.current_user.admin?
      flash[:warning] = "You must log in as administrator to perform this action."
      helpers.store_location
      redirect_to root_url
    end
  end
  
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
end
