class WalletsController < UsersController
  before_action :set_user
  before_action :set_wallet

  def show
    @transactions = Transaction.where(processable: @wallet.id).
                      or(Transaction.where(originable: @wallet.id)).limit(10)
  end

  private

    def set_wallet
      @wallet = @user.wallet
    end
end
