class CartsController < ApplicationController
  # Filters
  before_action :smart_return, only: [:add]
  before_action :set_product, only: [:add]
  before_action :set_cart


  def add
    if @current_cart.add(@product, @quantity)
      flash[:success] = "Successfully added #{@product.name} to your shopping cart."
    else
      flash[:warning] = "The product you have selected is out of stock"
    end
    redirect_back_or cart_path(@current_cart)
  end

  def show
  end

  private

    def set_cart
      @current_cart = helpers.current_cart
    end

    def set_product
      @quantity = params[:quantity].to_i || 1
      @product = Product.find_by(id: params[:pid])
      unless @product
        flash[:danger] = "The product you have selected is unavailable."
        redirect_to root_url
      #elsif @product.
        # TODO: PREVENT USER FROM ADDING DISABLED PRODUCT
      end
    end
end
