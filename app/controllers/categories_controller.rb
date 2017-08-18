class CategoriesController < ApplicationController

  def show
    @category = Category.find(params[:id])
    @products = @category.products.page(params[:page]).per(6)
  end
  
  def search
    search_term = params[:search_term] || ""
    unless search_term.empty?
      search = ProductSearchService.new(search_term)
      if params[:current_category] == 1
        @search_run = search.search_in_category(params[:category_id])
        @search_result = @search_run.page(params[:page]).per(6)
      else
        @search_run = search.quick_search
        @search_result = @search_run.page(params[:page]).per(6)
      end
    else
      flash.now[:warning] = "Please enter one or more search terms."
      render :search
    end
  end

end
