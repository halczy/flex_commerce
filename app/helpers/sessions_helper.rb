module SessionsHelper

  def login(user)
    session[:user_id] = user.id
  end

  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    elsif cookies.signed[:user_id]
      user = User.find(cookies.signed[:user_id])
      if user && user.authenticate_token?(:remember, cookies[:remember_token])
        login(user)
        @current_user = user
      end
    end
  end

  def logout(user)
    user.forget
    session.delete(:user_id)
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
    @current_user = nil
  end

end
