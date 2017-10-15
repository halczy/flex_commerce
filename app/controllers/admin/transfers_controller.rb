class Admin::TransfersController < Admin::AdminController

  def index
    filter = params[:filter] || ""
    transfers = Transfer.try(filter) || Transfer.all
    transfers = transfers.order(updated_at: :desc)
    @transfers = transfers.page params[:page]
  end

end
