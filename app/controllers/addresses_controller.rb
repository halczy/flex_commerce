class AddressesController < UsersController
  # Filters
  before_action :authenticate_user
  before_action :set_user
  before_action :set_address, only: [:edit, :update, :destroy]
  before_action :set_address_params, only: [:edit]
  before_action :populate_selector, only: [:new, :edit, :update_selector]

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
      flash[:success] = "Successfully added a new address to your account."
      redirect_to addresses_path
    else
      set_address_params
      populate_selector
      render :new
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      @address.build_full_address
      flash[:success] = "Successfully updated your address!"
      redirect_to addresses_path
    else
      set_address_params
      populate_selector
      render :edit
    end
  end

  def destroy
    if @address.destroyable?
      @address.destroy
      flash[:success] = "Successfully deleted an address from your account."
    else
      flash[:warning] = "The address cannot be deleted."
    end
    redirect_to addresses_path
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
      @community = Geo.find_by(id: params[:community_id])
    end

    def address_params
      params.require(:address).permit(:name, :recipient, :contact_number,
                                      :country_region, :province_state,
                                      :city, :district, :community, :street)
    end

    def set_address
      @address = Address.find(params[:id])
    end

    def set_address_params
      params[:province_id] = @address.province_state if @address.province_state.present?
      params[:city_id] = @address.city if @address.city.present?
      params[:district_id] = @address.district if @address.district.present?
      params[:community_id] = @address.community if @address.community.present?
    end

end
