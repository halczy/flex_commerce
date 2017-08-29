class ProductsController < ApplicationController
  before_action :set_product
  
  def show
    @images = @product.images.attachments.order(display_order: :asc)
  end

  private
    
    def set_product
      @product = Product.find(params[:id])
    end
end
