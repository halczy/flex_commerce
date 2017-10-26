class PermittedParams < Struct.new(:params)
  include Params::ShippingMethod
  # attr_accessor :params

  # def initialize(params)
    # @params = params
  # end

end
