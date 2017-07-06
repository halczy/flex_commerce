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
      @current_user ||= find_user(session[:user_id])
    elsif cookies.signed[:user_id]
      user = find_user(cookies.signed[:user_id])
      if user && user.authenticate_token?(:remember, cookies[:remember_token])
        login(user)
        @current_user = user
      end
    end
  end

  def current_user?(user)
    current_user == user
  end

  def signed_in?
    !current_user.nil?
  end

  def logout(user)
    user.forget
    clear_session_and_cookies
    @current_user = nil
  end

  private

    def find_user(session_user_id)
      begin
        User.find(session_user_id)
      rescue ActiveRecord::RecordNotFound
        clear_session_and_cookies
        return nil
      end
    end

    def clear_session_and_cookies
      session.delete(:user_id)
      cookies.delete(:user_id)
      cookies.delete(:remember_token)
    end
end
