class Admin::RewardMethodsController < Admin::AdminController
  before_action :set_reward_method, except: [ :index, :new, :create ]

  def index
    @reward_methods = RewardMethod.all
  end

  def new
    @reward_method = RewardMethod.new
  end

  def create
    @reward_method = RewardMethod.new(reward_method_params)
    if @reward_method.save
      flash[:success] = "Successfully created a reward method."
      set_settings
      redirect_to admin_reward_method_path(@reward_method)
    else
      render :new
    end
  end

  def show; end

  private

    def set_reward_method
      @reward_method = RewardMethod.find(params[:id])
    end

    def reward_method_params
      params.require(:reward_method).permit(:name, :variety)
    end

    def set_settings
      if @reward_method.referral? && params[:reward_method][:percentage]
        @reward_method.settings[:percentage] = params[:reward_method][:percentage]
      end
      @reward_method.save
    end
end
