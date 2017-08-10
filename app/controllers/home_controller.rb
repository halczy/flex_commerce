class HomeController < ApplicationController

  def index
    @feature_products = Category.feature.first.try(:products)
  end

end
