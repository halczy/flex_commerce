class Admin::ApplicationConfigurationsController < Admin::AdminController
  before_action :set_app_config, except: [ :index ]

  def index
    @app_configs = ApplicationConfiguration.all.order(created_at: :asc)
  end

  def edit; end

  def update
    if @app_config.update(app_config_params)
      flash[:success] = "Successfully updated the configuration."
      redirect_to admin_application_configurations_path
    else
      render :edit
    end
  end

  private

    def set_app_config
      @app_config = ApplicationConfiguration.find(params[:id])
    end

    def app_config_params
      params.require(:application_configuration).permit(:name, :value,
                                                        :plain, :status)
    end

end
