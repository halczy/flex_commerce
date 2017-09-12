class CartsController < ApplicationController
  # Filters
  before_action :smart_return,            only: [ :remove, :update ]
  before_action :set_product,             except: [ :show ]
  after_action  :validate_product,        only: [ :set_product ]
  before_action :set_quantity_for_add,    only: [ :add ]
  before_action :set_quantity_for_remove, only: [ :remove ]
  before_action :set_cart


  def add
    if @current_cart.add(@product, @quantity)
      flash[:success] = "Successfully added #{@product.name} to your shopping cart."
      redirect_to cart_path
    else
      smart_return
      flash[:warning] = 'The product you have selected is out of stock
                         or does not have enough stock to fill your request.'
      redirect_back_or cart_path
    end
  end

  def remove
    if @current_cart.remove(@product, @quantity)
      flash[:success] = "Successfully removed #{@product.name} from your shopping cart."
    else
      flash[:danger] = "Fail to remove #{@product.name} from you shopping cart."
    end
    redirect_back_or cart_path
  end

  def update
    @quantity =  @current_cart.inventories_diff(@product, params[:quantity].to_i)

    if @quantity > 0
      add
    elsif @quantity < 0
      @quantity = -@quantity
      remove
    end
  end

  def show
  end

  private

    def set_cart
      @current_cart = helpers.current_cart
    end

    def set_product
      @product = Product.find_by(id: params[:pid])
      unless @product
        flash[:danger] = "The product you have selected is unavailable."
        redirect_to root_url
      end
    end

    def validate_product
      # TODO: PREVENT USER FROM ADDING DISABLED PRODUCT
    end

    def set_quantity_for_add
      @quantity = params[:quantity].present? ? params[:quantity].to_i : 1
    end

    def set_quantity_for_remove
      @quantity = params[:quantity].to_i
    end
end
