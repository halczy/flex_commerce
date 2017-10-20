class CustomersController < UsersController
  # Filters
  before_action :authenticate_user, except: [ :new, :create ]
  before_action :set_user, except: [ :new, :create ]
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

  def show; end
  def edit; end

  def update
    if @user.update(customer_params)
      flash[:success] = "Successfully updated your profile."
      set_referral if params[:customer][:referer_id].present? && !@user.referer
      set_financial
      redirect_to @user
    else
      render :edit
    end
  end

  private

    def customer_params
      params.require(:customer).permit(:email, :cell_number, :name, :referer_id,
                                       :password, :password_confirmation)
    end

    def set_referral
      referer = User.find_by(id: params[:customer][:referer_id])
      if referer
        ref = Referral.create(referer: referer, referee: helpers.current_user)
        flash[:warning] = "#{ref.errors.full_messages.first}"
      end
      
    end

    def set_financial
      financial_params = ['alipay_account', 'bank_account', 'bank_name', 'bank_branch']
      financial_params.each do |fin|
        @user.settings[fin] = params['customer'][fin] if params['customer'][fin]
      end
      @user.save
    end

end
