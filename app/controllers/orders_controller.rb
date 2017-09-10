class OrdersController < UsersController
  # Filters
  before_action :set_order, except: [:create, :index]

  def create

  end

  def select_shipping

  end

  private

    def set_order
      @order = Order.find(params[:id])
    end




end
