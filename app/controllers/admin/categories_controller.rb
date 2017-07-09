class Admin::CategoriesController < Admin::AdminController

  def index
    @title = 'Categories'
    @top_level = Category.no_parent.order(:display_order)
    @categories = Category.all
  end

end
