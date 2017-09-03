class CustomersController < UsersController
  # Filters
  before_action :authenticate_user, only: [:show]
  before_action :set_user, only: [:show]

  def new
    @customer = Customer.new
  end

  def create
    helpers.convert_ident
    @customer = Customer.new(params_on_create)
    if @customer.save
      flash[:success] = 'Your account has been created successfully.'
      helpers.login(@customer)
      helpers.organize_cart(@customer)
      redirect_to dashboard_path(@customer)
    else
      render :new
    end
  end

  def show
  end

  private

    def params_on_create
      params.require(:customer).permit(:email, :cell_number, :name,
                                       :password, :password_confirmation)
    end

end
