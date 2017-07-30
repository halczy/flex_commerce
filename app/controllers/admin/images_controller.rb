class Admin::ImagesController < Admin::AdminController
  # Filters
  before_action :set_image, only: [:show, :destroy]

  def index
    @images = Image.all
  end

  def show
  end

  def create
    @image = Image.new(image_params)

    if @image.save
      render json: { id: @image.id, url: @image.image_url }.to_json
    else
      render json: @image.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @image.destroy
      flash[:success] = 'Image was successfully destroyed.'
      redirect_to admin_images_path
    end
  end

  private

    def set_image
      @image = Image.find(params[:id])
      @image_data = JSON.parse(@image.image_data) if @image.image_data
    end

    def image_params
      params.require(:image).permit(:image)
    end

end
