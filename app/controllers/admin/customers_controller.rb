class Admin::CustomersController < Admin::AdminController

  def index
    customers = Customer.all.order(updated_at: :desc)
    @customers = customers.page params[:page]
  end

end
