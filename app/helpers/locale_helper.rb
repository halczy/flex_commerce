module LocaleHelper

  def store_locale(locale)
    return false unless I18n.available_locales.include? locale.to_sym
    session[:locale] = locale
    cookies.permanent[:locale] = locale
  end

  def current_locale
    session[:locale] || cookies[:locale]
  end

  def clear_locale
    session.delete(:locale)
    cookies.delete(:locale)
  end

end
