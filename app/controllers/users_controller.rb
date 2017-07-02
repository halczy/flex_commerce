class UsersController < ApplicationController
  # Filters
  before_action :set_user, only: [:show]
  before_action :authenticate_user, only: [:show]
  before_action :correct_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    helpers.convert_ident
    @user = User.new(user_params_on_create)
    if @user.save
      @user.set_as_customer
      flash[:success] = 'Your account has been created successfully.'
      helpers.login(@user)
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def show
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params_on_create
      params.require(:user).permit(:email, :cell_number, :name,
                                   :password, :password_confirmation)
    end

    def correct_user
      redirect_to root_url unless helpers.current_user?(set_user)
    end
end
