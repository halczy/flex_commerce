  class CategoriesController < ApplicationController

  def show
    @category = Category.find(params[:id])
    available_products = @category.products.where(status: 'active')

    if params[:price_sort]
      sort = params[:price_sort] == 'asc' ? 'asc' : 'desc'
      available_products = available_products.order("price_member_cents #{sort}")
    end

    @products = available_products.page(params[:page]).per(6)
  end

  def search
    search_term = params[:search_term] || ""
    unless search_term.empty?
      search = ProductSearchService.new(search_term)
      if params[:current_category] == 1
        search_run = search.search_in_category(params[:category_id])
      else
        search_run = search.quick_search
      end
      search_run = search_run.where(status: 'active')
      @search_result = search_run.page(params[:page]).per(6)
    else
      flash.now[:warning] = "Please enter one or more search terms."
      render :search
    end
  end

end
