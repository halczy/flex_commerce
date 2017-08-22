class Admin::ProductsController < Admin::AdminController
  before_action :set_product, except: [:index, :new, :create, :search]

  def index
    @products = Product.order(updated_at: :desc).page params[:page]
  end

  def new
    @product = Product.new
    @image = @product.images.build
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      @product.associate_images
      flash[:success] = "Successfully created a product."
      redirect_to admin_product_path(@product)
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @product.update(product_params)
      @product.reassociate_images
      flash[:success] = "Successfully updated product."
      redirect_to admin_product_path(@product)
    else
      render :edit
    end
  end

  def destroy
    @product.unassociate_images
    if @product.destroy
      flash[:success] = "Product was successfully destroyed."
      redirect_to admin_products_path
    end
  end

  def search
    search_term = params[:search_term] || ""
    unless search_term.empty?
      @search_run = ProductSearchService.new(search_term).quick_search
      @search_result = @search_run.page params[:page]
    else
      flash.now[:warning] = "Please enter one or more search terms."
      render :search
    end
  end

  def inventories
    @inventories = @product.inventories
  end

  def add_inventories
    if params[:amount] && params[:amount].to_i > 0
      @product.add_inventories(params[:amount].to_i)
      flash[:success] = "Successfully created #{params[:amount]} inventories."
    else
      flash[:warning] = "Invalid Amount. Please enter a valid number."
    end

    redirect_to(inventories_admin_product_path(@product))
  end

  def remove_inventories

  end

  private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :tag_line, :sku, :introduction,
        :description, :specification, :digital, :strict_inventory, :price_market,
        :price_member, :price_reward, :cost, category_ids: [],
        images_attributes: [:id, :image, :display_order, :title, :description,
                            :in_use, :source_channel, :imageable_id,
                            :imageable_type])
    end
end
