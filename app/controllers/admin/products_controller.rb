class Admin::ProductsController < Admin::AdminController

  def index
    @products = Product.all
  end


end
