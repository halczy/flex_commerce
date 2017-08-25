class SessionsController < ApplicationController
  # Filters
  before_action :ident_finder, only: [:create]
  
  def new
  end

  def create
    if @user && @user.authenticate(params[:session][:password])
      helpers.login(@user)
      params[:session][:remember_me] == '1' ? helpers.remember(@user) : ""
      redirect_by_class(@user)
    else
      flash.now[:warning] = 'Incorrect account / password combination.'
      render :new
    end
  end

  def destroy
    user = User.find(params[:id])
    helpers.logout(user)
    flash[:info] = 'You are now logged out of your account.'
    redirect_to root_url
  end

  private
  
    def ident_finder
      helpers.convert_ident
      @user = User.find_by(email: params[:session][:email]) ||
              User.find_by(cell_number: params[:session][:cell_number]) ||
              User.find_by(member_id: params[:session][:member_id])
    end

    def redirect_by_class(user)
      if user.customer?
        redirect_back_or(customer_path(user))
      elsif user.admin?
        redirect_back_or(admin_dashboard_index_path)
      end
    end
end
