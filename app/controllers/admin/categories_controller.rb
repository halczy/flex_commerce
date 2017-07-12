class Admin::CategoriesController < Admin::AdminController
  # Filters
  before_action :set_category, only: [:show, :edit, :edit, :update]

  def index
    @top_level = Category.no_parent.order(:display_order)
    @categories = Category.all
  end

  def new
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

  def show
  end

  def edit
  end

  def update
    if @category.update(category_params)
      flash[:success] = "Successfully updated the category."
      redirect_to admin_categories_path
    else
      render :edit
    end
  end

  private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:parent_id, :name, :display_order, :hide)
    end

end
