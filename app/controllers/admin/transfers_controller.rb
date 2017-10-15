class Admin::TransfersController < Admin::AdminController

  def index
    @transfers = Transfer.all
  end

end
