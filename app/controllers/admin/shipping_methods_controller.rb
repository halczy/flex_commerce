class Admin::ShippingMethodsController < Admin::AdminController
  # Filter
  before_action :geo_code_reference, only: [:new]

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
      redirect_to admin_shipping_methods_path
    else
      geo_code_reference
      render :new
    end
  end

  private

    def geo_code_reference
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
