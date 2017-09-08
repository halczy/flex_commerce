class Admin::ShippingMethodsController < Admin::AdminController
  # Filter

  def index
    @shipping_methods = ShippingMethod.all
  end

end
