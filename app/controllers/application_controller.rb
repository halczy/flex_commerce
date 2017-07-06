class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def authenticate_user
    unless helpers.signed_in?
      # TODO FLASH MESSAGE
      redirect_to signin_path
    end
  end

  def authenticate_admin
    unless helpers.current_user.admin?
      # TODO FLASH MESSAGE
      redirect_to root_url
    end
  end
end
