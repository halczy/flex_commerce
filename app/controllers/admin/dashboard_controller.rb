class Admin::DashboardController < Admin::AdminController

  def index
    @to_confirm_orders = Order.payment_success
    @to_ship_orders = Order.staff_confirmed
    # PENDING TRANSFER
    # OOS Product
  end

end
