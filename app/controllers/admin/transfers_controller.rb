class Admin::TransfersController < Admin::AdminController

  def index
    status = params[:status] || ""
    transfers = Transfer.try(status) || Transfer.all
    transfers = transfers.order(updated_at: :desc)
    @transfers = transfers.page params[:page]
  end

end
