class Admin::TransfersController < Admin::AdminController
  before_action :set_transfer, except: [ :index ]

  def index
    filter = params[:filter] || ""
    transfers = Transfer.try(filter) || Transfer.all
    transfers = transfers.order(updated_at: :desc)
    @transfers = transfers.page params[:page]
  end

  def show; end

  def approve
    if @transfer_service.execute_transfer
      flash[:success] = "Transfer approved!"
    else
      flash[:warning] = "Transfer fail."
    end
    redirect_to admin_transfer_path(@transfer)
  end

  private

    def set_transfer
      @transfer = Transfer.find(params[:id])
      @transfer_service = TransferService.new(transfer_id: @transfer.id)
    end
end
