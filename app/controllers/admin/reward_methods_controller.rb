class Admin::RewardMethodsController < Admin::AdminController
  before_action :set_reward_method, except: [:index, :new, :create]

  def index
    @reward_methods = RewardMethod.all.order(updated_at: :desc).page params[:page]
  end

  def new
    @reward_method = RewardMethod.new
  end

  def create
    @reward_method = RewardMethod.new(reward_method_params)
    if @reward_method.save
      flash[:success] = t('.success')
      set_settings
      redirect_to admin_reward_method_path(@reward_method)
    else
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @reward_method.update(reward_method_params)
      flash[:success] = t('.success')
      set_settings
      redirect_to admin_reward_method_path(@reward_method)
    else
      render :edit
    end
  end

  def destroy
    if @reward_method.destroyable?
      @reward_method.destroy
      flash[:success] = t('.success')
    else
      flash[:warning] = t('.warning')
    end
    redirect_to admin_reward_methods_path
  end

  private

    def set_reward_method
      @reward_method = RewardMethod.find(params[:id])
    end

    def reward_method_params
      params.require(:reward_method).permit(:name, :variety)
    end

    def set_settings
      if @reward_method.referral? && params[:reward_method][:percentage]
        @reward_method.settings['percentage'] = params[:reward_method][:percentage]
      end
      if @reward_method.cash_back? && params[:reward_method][:percentage]
        @reward_method.settings['percentage'] = params[:reward_method][:percentage]
      end
      @reward_method.save
    end
end
