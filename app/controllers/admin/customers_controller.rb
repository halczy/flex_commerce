class Admin::CustomersController < Admin::AdminController
  before_action :set_customer, except: [ :index, :search ]

  def index
    customers = Customer.all.order(updated_at: :desc)
    @customers = customers.page params[:page]
  end

  def search
    search_term = params[:search_term] || ""
    unless search_term.empty?
      @search_run = CustomerSearchService.new(search_term).search
      @search_result = @search_run.page params[:page]
    else
      flash.now[:warning] = t('.warning')
      render :search
    end
  end

  def show; end
  def edit; end

  def update
    if @customer.update(customer_params)
      flash[:success] = t('.success')
      redirect_to admin_customer_path(@customer)
    else
      render :edit
    end
  end

  private

    def set_customer
      @customer = Customer.find(params[:id])
    end

    def customer_params
      params.require(:customer).permit(:member_id, :name, :email, :cell_number)
    end

end
