class Admin::ApplicationConfigurationsController < Admin::AdminController

  def index
    @app_configs = ApplicationConfiguration.all
  end

end
