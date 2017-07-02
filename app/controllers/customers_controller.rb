class CustomersController < UsersController
  # Filters
  before_action :set_customer, only: [:show]
  before_action :authenticate_user, only: [:show]
  before_action :correct_customer, only: [:show]

  def new
    @customer = Customer.new
  end

  def create
    helpers.convert_ident
    @customer = Customer.new(params_on_create)
    if @customer.save
      flash[:success] = 'Your account has been created successfully.'
      helpers.login(@customer)
      redirect_to @customer
    else
      render :new
    end
  end

  def show
  end

  private

    def set_customer
      @customer = User.find(params[:id])
    end

    def params_on_create
      params.require(:customer).permit(:email, :cell_number, :name,
                                       :password, :password_confirmation)
    end

    def correct_customer
      unless helpers.current_user?(set_customer)
        # TODO FLASH MESSAGE
        redirect_to root_url
      end
    end

end
