class CartsController < ApplicationController
  # Filters
  before_action :smart_return,            only:   [ :remove, :update ]
  before_action :set_product,             except: [ :show ]
  before_action :validate_product,        only:   [ :add ]
  before_action :set_quantity_for_add,    only:   [ :add ]
  before_action :set_quantity_for_remove, only:   [ :remove ]
  before_action :set_cart

  def add
    if @current_cart.add(@product, @quantity)
      flash[:success] = t('carts.add.success', product: @product.name)
      redirect_to cart_path
    else
      smart_return
      flash[:warning] = t('carts.add.warning', product: @product.name)
      redirect_back_or cart_path
    end
  end

  def remove
    if @current_cart.remove(@product, @quantity)
      flash[:success] = t('controller.carts.success', product: @product.name)
    else
      flash[:danger] = t('carts.remove.danger', product: @product.name)
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
        flash[:danger] = t('carts.set_product.danger')
        redirect_to root_url
      end
    end

    def validate_product
      if @product.disabled?
        flash[:danger] = t('.carts.validate_product.danger')
        redirect_to(root_url) and return
      end
    end

    def set_quantity_for_add
      @quantity = params[:quantity].present? ? params[:quantity].to_i : 1
    end

    def set_quantity_for_remove
      @quantity = params[:quantity].to_i
    end
end
