class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Rescue
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  # Callbacks
  before_action :page_speed
  before_action :set_locale

  def render_404
   respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", layout: false, status: :not_found }
      format.any { head :not_found }
    end
  end

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

  def smart_return
    helpers.store_return_url if params[:return_back] == "true"
  end

  def page_speed
    @init_time = Time.zone.now
  end

  private

    def set_locale
      I18n.locale = helpers.current_locale.try(:to_sym) || I18n.locale = I18n.default_locale
    end
end
