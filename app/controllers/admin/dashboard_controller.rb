class Admin::DashboardController < Admin::AdminController

  def index
    @pd_confirm_orders = Order.payment_success
    @pd_shipment_orders = Order.staff_confirmed
    @pd_pickup_orders = Order.pickup_pending
    @pd_delivery_orders = Order.shipped
    @pd_withdraws = Transfer.pending
    # OOS Product
  end

end
