module CartsHelper

  def current_cart
    if current_user
      @current_cart ||= Cart.find_or_create_by(user: current_user)
    else
      @current_cart ||= find_or_create_session_cart
    end
  end

  def find_or_create_session_cart
    cart = Cart.find_by(id: session[:cart_id]) || Cart.create
    session[:cart_id] = cart.id if session[:cart_id] != cart.id
    cart
  end

end
