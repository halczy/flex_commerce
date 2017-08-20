class Admin::InventoriesController < Admin::AdminController

  def index
    @products = Product.all.page(params[:page])
  end

end
