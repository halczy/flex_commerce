class WalletsController < UsersController
  before_action :set_user
  before_action :set_wallet

  def show
    @transactions = Transaction.where(processable: @wallet.id)
                               .or(Transaction.where(originable: @wallet.id))
                               .order(created_at: :desc)
                               .limit(10)
  end

  def show_transactions
    @transactions = Transaction.where(processable: @wallet.id)
                               .or(Transaction.where(originable: @wallet.id))
                               .order(created_at: :desc)
                               .page params[:page]
  end

  def show_transfer_ins
    @transfers = Transfer.where(fund_target: @wallet).order(created_at: :desc)
                         .page params[:page]
  end

  def show_transfer_outs
    @transfers = Transfer.where(fund_target: @wallet).order(created_at: :desc)
                         .page params[:page]
  end

  private

    def set_wallet
      @wallet = @user.wallet
    end
end
