class SessionsController < ApplicationController
  # Filters
  before_action :ident_finder, only: [:create]

  def new
  end

  def create
    if @user && @user.authenticate(params[:session][:password])
      helpers.login(@user)
      helpers.organize_cart(@user)
      helpers.remember(@user) if params[:session][:remember_me] == '1'
      redirect_by_class(@user)
    else
      flash.now[:warning] = t('.warning')
      render :new
    end
  end

  def destroy
    user = User.find(params[:id])
    helpers.logout(user)
    flash[:info] = t('.info')
    redirect_to root_url
  end

  private

    def ident_finder
      helpers.convert_ident
      @user = User.where.not(email: nil).find_by(email: params[:session][:email]) ||
              User.where.not(cell_number: nil).find_by(cell_number: params[:session][:cell_number]) ||
              User.where.not(member_id: nil).find_by(member_id: params[:session][:member_id])
    end

    def redirect_by_class(user)
      if user.customer?
        redirect_back_or(dashboard_path(user))
      elsif user.admin?
        redirect_back_or(admin_dashboard_index_path)
      end
    end
end
