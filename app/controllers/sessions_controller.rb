class SessionsController < ApplicationController

  def new
    @title = 'Sign In'
  end

  def create
    user = User.find_by(email: params[:session][:ident]) ||
           User.find_by(cell_number: params[:session][:ident])
    if user && user.authenticate(params[:session][:password])
      helpers.login(user)
      params[:session][:remember_me] == '1' ? helpers.remember(user) : ""
      redirect_to customer_path(user)
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
end
