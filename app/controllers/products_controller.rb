class ProductsController < ApplicationController

  def show
    @product = Product.find(params[:id])
    @images = @product.images.attachments.order(display_order: :asc)
  end

end
