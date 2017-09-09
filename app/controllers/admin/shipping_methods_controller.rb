class Admin::ShippingMethodsController < Admin::AdminController
  # Filter
  before_action :populate_form, only: [:new, :edit]
  before_action :set_shipping_method, only: [:show, :edit, :update, :destroy]

  def index
    @shipping_methods = ShippingMethod.all
  end

  def new
    @shipping_method =  ShippingMethod.new
    @address = @shipping_method.addresses.build
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
      flash[:success] = 'Successfully created a shipping method.'
      @shipping_method.try(:addresses).try(:first).try(:build_full_address)
      redirect_to admin_shipping_method_path(@shipping_method)
    else
      populate_form
      render :new
    end
  end

  def show
    @shipping_rates = @shipping_method.try(:shipping_rates)
    @address = @shipping_method.try(:addresses).try(:last)
  end

  def edit
  end

  def update
    case params[:shipping_method][:variety]
    when 'no_shipping'
      update_status = @shipping_method.update(no_shipping_params)
    when 'delivery'
      update_status = @shipping_method.update(delivery_params)
    when 'self_pickup'
      update_status = @shipping_method.update(self_pickup_params)
    end

    if update_status
      flash[:success] = 'Successfully edited shipping method.'
      @shipping_method.try(:addresses).try(:first).try(:build_full_address)
      redirect_to admin_shipping_method_path(@shipping_method)
    else
      populate_form
      render :edit
    end
  end

  def destroy
    if @shipping_method.destroy
      flash[:success] = "Successfully removed the selected shipping method."
    else
      flash[:danger] = "This shipping method cannot be deleted."
    end
    redirect_to admin_shipping_methods_path
  end

  private

    def set_shipping_method
      @shipping_method = ShippingMethod.find(params[:id])
    end

    def populate_form
      @address = @shipping_method.addresses.build if @shipping_method
      @provinces = Geo.province_state
    end

    def no_shipping_params
      params.require(:shipping_method).permit(:name, :variety)
    end

    def delivery_params
      params.require(:shipping_method).permit(
        :name, :variety,
        shipping_rates_attributes: [:id, :geo_code, :init_rate, :add_on_rate,
                                    :_destroy])
    end

    def self_pickup_params
      params.require(:shipping_method).permit(
        :name, :variety,
        shipping_rates_attributes: [:id, :geo_code, :init_rate, :add_on_rate,
                                    :_destroy],
        addresses_attributes: [:id, :province_state, :street, :recipient,
                               :contact_number, :addressable_id, :addressable_type])
    end
end
