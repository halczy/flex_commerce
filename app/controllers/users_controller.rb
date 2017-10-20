class UsersController < ApplicationController

  private

    def set_user
      @user = User.find_by(id: params[:id]) || helpers.current_user
      validate_permission
    end

    def validate_permission
      unless helpers.current_user?(@user) || helpers.current_user.try(:admin?)
        flash[:danger] = t('users.validate_permission.danger')
        redirect_to root_url
      end
    end
end
