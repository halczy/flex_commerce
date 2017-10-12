class RewardsController < UsersController
  before_action :set_user

  def show
    rewards = Transaction.all.select do |t|
      t.originable.try("reward?") &&
      t.processable == @user.wallet
    end
    @rewards = Kaminari.paginate_array(rewards).page params[:page]
  end

end
