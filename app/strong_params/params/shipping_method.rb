module Params
  module ShippingMethod
    def shipping_method
      params.require(:shipping_method).permit(*shipping_method_attributes)
    end

    def shipping_method_attributes
      variety = params['shipping_method']['variety']
      shipping_rates_attrs = [:id, :geo_code, :init_rate, :add_on_rate, :_destroy]
      address_attrs = [:id, :province_state, :street, :recipient,
                       :contact_number, :addressable_id, :addressable_type]

      Array.new.tap do |attributes|
        attributes << :name
        attributes << :variety
        if variety == 'delivery' || variety == 'self_pickup'
          attributes <<  { shipping_rates_attributes: shipping_rates_attrs }
        end
        if variety == 'self_pickup'
          attributes << { address_attributes: address_attrs }
        end
      end
    end

  end
end
