class Admin::ShippingMethodsController < Admin::AdminController
  # Filter
  before_action :populate_form, only: [:new, :edit]
  before_action :set_shipping_method, only: [:show, :edit, :update, :destroy]

  def index
    @shipping_methods = ShippingMethod.all
  end

  def new
    @shipping_method =  ShippingMethod.new
    @address = @shipping_method.build_address
  end

  def create
    case params[:shipping_method][:variety]
    when 'no_shipping'
      @shipping_method = ShippingMethod.new(no_shipping_params)
    when 'delivery'
      @shipping_method = ShippingMethod.new(delivery_params)
    when 'self_pickup'
      @shipping_method = ShippingMethod.new(self_pickup_params)
    end

    if @shipping_method.save
      flash[:success] = t('.success')
      @shipping_method.try(:address).try(:build_full_address)
      redirect_to admin_shipping_method_path(@shipping_method)
    else
      populate_form
      render :new
    end
  end

  def show
    @shipping_rates = @shipping_method.try(:shipping_rates)
    @address = @shipping_method.try(:address)
  end

  def edit; end

  def update
    if @shipping_method.update(permitted_params.shipping_method)
      flash[:success] = t('.success')
      @shipping_method.try(:address).try(:build_full_address)
      redirect_to admin_shipping_method_path(@shipping_method)
    else
      populate_form
      render :edit
    end
  end

  def destroy
    if @shipping_method.destroyable? && @shipping_method.destroy
      flash[:success] = t('.success')
    else
      flash[:danger] = t('.danger')
    end
    redirect_to admin_shipping_methods_path
  end

  private

    def set_shipping_method
      @shipping_method = ShippingMethod.find(params[:id])
    end

    def populate_form
      @address = @shipping_method.build_address if @shipping_method
      @provinces = Geo.province_state
    end
end
