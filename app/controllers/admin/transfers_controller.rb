class Admin::TransfersController < Admin::AdminController
  before_action :set_transfer, except: [ :index ]

  def index
    filter = params[:filter] || ""
    transfers = Transfer.try(filter) || Transfer.all
    transfers = transfers.order(updated_at: :desc)
    @transfers = transfers.page params[:page]
  end

  def show; end

  private

    def set_transfer
      @transfer = Transfer.find(params[:id])
    end
end
