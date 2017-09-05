class AddressesController < UsersController
  # Filters
  before_action :authenticate_user
  before_action :set_user
  before_action :populate_selector, only: [:new, :update_selector]

  def index
    @addresses = @user.addresses
  end

  def new
    @address = Address.new
  end

  def create
    @address = @user.addresses.new(address_params)
    if @address.save
      @address.build_full_address
      flash[:success] = "Successfully created an address"
      redirect_to addresses_path
    else
      populate_selector
      render :new
    end
  end

  def update_selector
    respond_to do |format|
      format.js
    end
  end

  private

    def populate_selector
      @provinces = Geo.cn.children
      @province = Geo.find_by(id: params[:province_id])

      @cities = @province.try(:children) || []
      @city = Geo.find_by(id: params[:city_id])

      @districts = @city.try(:children) || []
      @district = Geo.find_by(id: params[:district_id])

      @communities = @district.try(:children) || []
    end

    def address_params
      params.require(:address).permit(:name, :recipient, :contact_number,
                                      :country_region, :province_state,
                                      :city, :district, :community, :street)
    end

end
