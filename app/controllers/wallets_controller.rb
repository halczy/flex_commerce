class WalletsController < UsersController
  before_action :set_user
  before_action :set_wallet

  def show; end

  private

    def set_wallet
      @wallet = @user.wallet
    end
end
