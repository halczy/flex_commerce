class Admin::ImagesController < Admin::AdminController
  # Filters
  before_action :set_image, only: [:show, :destroy]
  def index
    @images = Image.all
  end

  def show
  end

  private

    def set_image
      @image = Image.find(params[:id])
      @image_data = JSON.parse(@image.image_data) if @image.image_data
    end

end
