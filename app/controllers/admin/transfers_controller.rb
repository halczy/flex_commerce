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
      flash[:success] = t('.success')
    else
      flash[:warning] = t('.warning')
    end
    redirect_to admin_transfer_path(@transfer)
  end

  def manual_approve_alipay
    if @transfer_service.manual_alipay_transfer
      flash[:success] = t('.success')
    else
      flash[:warning] = t('.warning')
    end
    redirect_to admin_transfer_path(@transfer)
  end

  def reject
    if @transfer_service.cancel_transfer
      flash[:success] = t('.success')
    else
      flash[:warning] = t('.warning')
    end
    redirect_to admin_transfer_path(@transfer)
  end

  private

    def set_transfer
      @transfer = Transfer.find(params[:id])
      @transfer_service = TransferService.new(transfer_id: @transfer.id)
    end
end
