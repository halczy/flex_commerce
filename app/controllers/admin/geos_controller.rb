class Admin::GeosController < Admin::AdminController

  def index
    geo_filter = params[:geo_filter] ||= ""
    geos = Geo.try(geo_filter) || Geo.all
    @geos = geos.page params[:page]
  end

  def search
    search_term = params[:search_term] || ''
    if search_term.present?
      @search_run = GeoSearchService.new(search_term).full_search
      @search_result = @search_run.page params[:page]
    else
      flash.now[:warning] = t('.warning')
      render :search
    end
  end

end
