class Admin::ImagesController < Admin::AdminController
  # Filters
  before_action :set_image, only: [:show, :destroy]
  before_action :smart_return, only: [:destroy]

  def index
    @images = Image.order(updated_at: :desc).page params[:page]
  end

  def show
    @image_data = JSON.parse(@image.image_data) if @image.image_data
  end

  def create
    @image = Image.new(image_params)

    if @image.save
      render json: { id: @image.id, url: @image.image_url(:fit) }.to_json
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @image.destroy
      flash[:success] = t('.success')
    else
      flash[:danger] = t('.danger')
    end
    redirect_back_or admin_images_path
  end

  private

    def set_image
      @image = Image.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:image)
    end

end
