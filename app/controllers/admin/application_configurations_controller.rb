class Admin::ApplicationConfigurationsController < Admin::AdminController
  before_action :set_app_config, except: [ :index ]

  def index
    @app_configs = ApplicationConfiguration.all.order(created_at: :asc)
  end

  def edit; end

  private

    def set_app_config
      @app_config = ApplicationConfiguration.find(params[:id])
    end

end
