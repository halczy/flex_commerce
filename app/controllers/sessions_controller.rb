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
      redirect_to user
    else
      render :new
    end
  end

  def destroy
    user = User.find(params[:id])
    helpers.logout(user)
    redirect_to root_url
  end
end
