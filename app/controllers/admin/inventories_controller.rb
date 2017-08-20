class Admin::InventoriesController < Admin::AdminController

  def index
    @products = Product.all
  end

end
