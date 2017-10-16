class DashboardsController < UsersController
  # Filters
  before_action :authenticate_user
  before_action :set_user

  def show
    @wallet = @user.wallet
    @creation_process_orders = Order.creation_process(@user)
    @payment_process_orders = Order.payment_process(@user)
    @shipment_orders = Order.where(user: @user)
                            .where("status >= 70 AND status <= 90")
  end
end
