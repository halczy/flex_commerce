class Admin::CategoriesController < Admin::AdminController
  # Filters
  before_action :set_category, only: [:edit]

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

  def edit
  end

  private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:parent_id, :name, :display_order, :hide)
    end

end
