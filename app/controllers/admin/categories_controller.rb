class Admin::CategoriesController < Admin::AdminController
  # Filters
  before_action :set_category, except: [:index, :new, :create]

  def index
    @top_level = Category.no_parent.order(:display_order)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      flash[:success] = 'Category has been created successfully.'
      redirect_to admin_category_path(@category)
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
      redirect_to admin_category_path(@category)
    else
      render :edit
    end
  end

  def destroy
    @category.unassociate_children
    if @category.destroy
      flash[:success] = "Deleted category successfully."
      redirect_to admin_categories_path
    end
  end

  def move
    position = params[:position].to_i || 0
    if @category.move(position)
      redirect_to admin_categories_path
    else
      flash[:danger] = "Cannot move category to that position."
      redirect_to admin_categories_path
    end
  end

  def move_down

  end

  private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:parent_id, :name, :display_order, :hide)
    end

end
