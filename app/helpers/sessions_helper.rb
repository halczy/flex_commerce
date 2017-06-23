module SessionsHelper

  def login(user)
    session[:user_id] = user.id
  end

  def remember(user)
    user.regenerate_remember_token
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

end
