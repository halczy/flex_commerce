class Admin::ProductsController < Admin::AdminController
  # Filters
  before_action :set_product, except: [:index, :new, :create, :search]
  before_action :validate_amount, only: [:add_inventories, :remove_inventories,
                                         :force_remove_inventories]

  def index
    case params[:display]
    when 'in_stock'
      products = Product.in_stock.distinct
    when 'out_of_stock'
      products = Product.out_of_stock.distinct
    else
      products = Product.all
    end

    @products = products.order(updated_at: :desc).page params[:page]
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

  def show; end

  def edit; end

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
    if @product.destroyable?
      @product.destroy
      flash[:success] = "Successfully destroyed the product."
    else
      @product.disable
      flash[:success] = "Successfully disabled the product."
    end
    redirect_to admin_products_path
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
    if @product.add_inventories(@amount)
      flash[:success] = "Successfully created #{@amount} inventories."
      redirect_to(inventories_admin_product_path(@product))
    end
  end

  def remove_inventories
    if @product.remove_inventories(@amount)
      flash[:success] = "Successfully deleted #{@amount} inventories."
    else
      flash[:danger] = "The requested amount exceeds unsold inventories."
    end
    redirect_to(inventories_admin_product_path(@product))
  end

  def force_remove_inventories
    inv_before = @product.inventories.count
    @product.force_remove_inventories(@amount)
    inv_deleted = inv_before - @product.inventories.count
    flash[:info] = "Successfully force deleted #{inv_deleted} inventories."
    redirect_to(inventories_admin_product_path(@product))
  end

  private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :tag_line, :sku, :introduction,
        :description, :specification, :digital, :strict_inventory,
        :price_market, :price_member, :price_reward, :cost, :status, :weight,
        category_ids: [], shipping_method_ids: [], reward_method_ids: [],
        images_attributes: [:id, :image, :display_order, :title, :description,
                            :in_use, :source_channel, :imageable_id,
                            :imageable_type])
    end

    def validate_amount(action = 'add')
      if params[:amount] && params[:amount].to_i <= 0
        flash[:danger] = "Invalid Amount. Please enter a valid number."
        redirect_to(inventories_admin_product_path(@product))
      else
        @amount = params[:amount].to_i
      end
    end
end
