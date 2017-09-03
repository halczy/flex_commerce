class AddressesController < UsersController
  # Filters
  before_action :authenticate_user
  before_action :set_user
  before_action :populate_selector, only: [:new, :update_selector]

  def new
    @address =  Address.new
  end

  def create
    raise
  end

  def update_selector
    respond_to do |format|
      format.js
    end
  end

  def populate_selector
    @provinces = Geo.cn.children
    @province = Geo.find_by(id: params[:province_id])

    @cities = @province.try(:children) || []
    @city = Geo.find_by(id: params[:city_id])

    @districts = @city.try(:children) || []
    @district = Geo.find_by(id: params[:district_id])

    @communities = @district.try(:children) || []
  end
end
