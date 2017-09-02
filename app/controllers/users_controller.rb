class UsersController < ApplicationController

  private

    def set_user
      @user = User.find(params[:id])
      validate_permission
    end

    def validate_permission
      unless helpers.current_user?(@user) || helpers.current_user.admin?
        flash[:danger] = "Access Denied"
        redirect_to root_url
      end
    end
end
