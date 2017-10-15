class WalletsController < UsersController
  before_action :set_user
  before_action :set_wallet, except: [ :show_withdraw ]
  before_action :set_processors, only: [ :new_withdraw ]
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

  def show_withdraw; end

  def create_withdraw
    ts = TransferService.new(
      transferer_id: @user,
      transferee_id: @user,
      amount: params[:amount],
      processor: params[:processor]
    )

    if ts.create
      flash[:success] = "Successfully created a withdraw request."
      redirect_to show_withdraw_wallet_path(id: @user.id, transfer_id: ts.transfer.id)
    else
      flash[:warning] = "Unable to initialize transfer request. Please double
                         check your withdrawable amount."
      redirect_to new_withdraw_wallet_path(@user)
    end
  end

  def show_withdraw
    @transfer = Transfer.find(params[:transfer_id])
  end

  def show_withdraws
    transfers = Transfer.where.not(processor: 0).where(transferer: @user)
    @transfers = transfers.order(created_at: :desc).page params[:page]
  end

  private

    def set_wallet
      @wallet = @user.wallet
    end

    def set_processors
      @processors =  Array.new.tap do |processor|
        processor << ['Alipay', 'alipay'] if @user.alipay_account.present?
        processor << ['Bank', 'bank'] if @user.bank_account.present?
      end
    end

    def require_financial
      if @processors.empty?
        flash[:warning] = "Please provide your Alipay account or
                           bank account information before requesting a
                           withdraw"
        redirect_to edit_customer_path(@user)
      end
    end
end
