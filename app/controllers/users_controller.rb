class UsersController < ApplicationController
  # Filters
  before_action :authenticate_user, only: [:show]
  before_action :set_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    helpers.convert_ident
    @user = User.new(user_params_on_create)
    if @user.save
      redirect_to @user
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

end
