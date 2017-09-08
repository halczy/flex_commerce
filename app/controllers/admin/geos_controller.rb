class Admin::GeosController < Admin::AdminController

  def index
    geo_filter = params[:geo_filter] ||= ""
    geos = Geo.try(geo_filter) || Geo.all
    @geos = geos.page params[:page]
  end

end
