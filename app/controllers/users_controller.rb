class UsersController < ApplicationController

  private

    def set_user
      @user = User.find_by(id: params[:id]) || helpers.current_user
      validate_permission
    end

    def validate_permission
      unless helpers.current_user?(@user) || helpers.current_user.admin?
        flash[:danger] = "Access Denied"
        redirect_to root_url
      end
    end
end
