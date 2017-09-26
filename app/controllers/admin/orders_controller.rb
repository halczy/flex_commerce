class Admin::OrdersController < Admin::AdminController

  def index
    status = params[:status] ||= ""
    orders = Order.try(status) || Order.all
    orders = orders.order(updated_at: :desc)
    @orders = orders.page params[:page]
  end

end
