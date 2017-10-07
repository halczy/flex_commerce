class Admin::WalletsController < Admin::AdminController
  before_action :smart_return
  before_action :reset_admin_balance, only: [ :deposit ]

  def deposit
    transfer_service = TransferService.new(
      transferer_id: params[:transferer_id],
      transferee_id: params[:transferee_id],
      amount: params[:amount]
    )
    if transfer_service.create && transfer_service.execute_transfer
      flash[:success] = "Successfully deposited into customer account."
    else
      flash[:warning] = 'Transfer fail. Please check customer ident or amount.'
    end
    redirect_back_or admin_customer_path(params[:transferee_id])
  end

  private

    def reset_admin_balance
      helpers.current_user.wallet.update(balance: 100000)
    end

end
