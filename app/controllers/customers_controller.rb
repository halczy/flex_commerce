class CustomersController < UsersController
  # Filters
  before_action :authenticate_user, only: [ :show ]
  before_action :set_user, only: [ :show ]
  after_action  :set_referral, only: [ :create ]

  def new
    @customer = Customer.new
  end

  def create
    helpers.convert_ident
    @customer = Customer.new(customer_params)
    if @customer.save
      flash[:success] = 'Your account has been created successfully.'
      helpers.login(@customer)
      helpers.organize_cart(@customer)
      redirect_back_or dashboard_path(@customer)
    else
      render :new
    end
  end

  def show
  end

  private

    def customer_params
      params.require(:customer).permit(:email, :cell_number, :name,
                                       :password, :password_confirmation)
    end

    def set_referral
      referer = User.find_by(id: params[:customer][:referer_id])
      if referer
        Referral.create!(referer: referer, referee: helpers.current_user)
      end
    end

end
