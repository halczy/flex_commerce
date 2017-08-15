class CategoriesController < ApplicationController

  def show
    @category = Category.find(params[:id])
    # @refined_categories = @category.refine
    @products = @category.products
  end

end
