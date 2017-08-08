class Admin::ProductsController < Admin::AdminController
  before_action :set_product, except: [:index, :new, :create]

  def index
    @products = Product.all
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
