class Admin::ShippingMethodsController < Admin::AdminController
  # Filter
  before_action :geo_code_reference, only: [:new]

  def index
    @shipping_methods = ShippingMethod.all
  end

  def new
    @shipping_method =  ShippingMethod.new
  end

  private

    def geo_code_reference
      @provinces = Geo.province_state
    end
end
