class Admin::CategoriesController < Admin::AdminController

  def index
    @title = 'Categories'
    @top_level = Category.no_parent.order(:display_order)
    @categories = Category.all
  end

  def new
    @title = 'New Category'
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:success] = 'Category has been created successfully.'
      redirect_to admin_categories_path
    else
      render :new
    end
  end

  private

    def category_params
      params.require(:category).permit(:parent_id, :name, :display_order, :hide)
    end

end
