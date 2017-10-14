class WalletsController < UsersController
  before_action :set_user
  before_action :set_wallet
  before_action :require_financial, only: [ :new_withdraw ]

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
    @transfers = Transfer.where(fund_source: @wallet).order(created_at: :desc)
                         .page params[:page]
  end

  def new_withdraw; end

  private

    def set_wallet
      @wallet = @user.wallet
    end

    def require_financial
      unless @user.alipay_account.present? || @user.bank_account.present?
        flash[:warning] = "Please provide your Alipay account or
                           bank account information before requesting a
                           withdraw"
        redirect_to edit_customer_path(@user)
      end
    end
end
