class Admin::RewardMethodsController < Admin::AdminController

  def index
    @reward_methods = RewardMethod.all
  end

  def new
    @reward_method = RewardMethod.new
  end

end
