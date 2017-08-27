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

  def organize_cart(user)
    if session[:cart_id]
      session_cart = Cart.find_by(id: session[:cart_id])
      session_cart.migrate_to(user) if session_cart
      cart_session_cleanup
      session_cart.destroy
    end
  end

  private

    def cart_session_cleanup
      session.delete(:cart_id)
    end

end
