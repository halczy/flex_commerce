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
      flash.now[:warning] = "Please enter one or more search terms."
      render :search
    end
  end

  def show; end
  def edit; end

  private

    def set_customer
      @customer = Customer.find(params[:id])
    end

end
