class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def authenticate_user
    unless helpers.signed_in?
      redirect_to signin_path
    end
  end
end
