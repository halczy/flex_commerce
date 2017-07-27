class Admin::ImagesController < Admin::AdminController

  def index
    @images = Image.all
  end

end
