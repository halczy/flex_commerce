class SessionsController < ApplicationController

  def new
    @title = 'Sign In'
  end

  def create
    user = User.find_by(email: params[:session][:ident]) ||
           User.find_by(cell_number: params[:session][:ident])
    if user && user.authenticate(params[:session][:password])
      helpers.login(user)
      redirect_to user
    else
      render :new
    end
  end

end
