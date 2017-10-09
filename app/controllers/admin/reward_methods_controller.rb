class Admin::RewardMethodsController < Admin::AdminController

  def index
    @reward_methods = RewardMethod.all
  end

end
