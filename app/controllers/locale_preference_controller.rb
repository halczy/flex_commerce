class LocalePreferenceController < ApplicationController
  before_action :smart_return

  def create
    helpers.store_locale(params[:locale])
    redirect_back_or root_url
  end

  def destroy
    helpers.clear_locale
    redirect_back_or root_url
  end

end
