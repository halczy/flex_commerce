class SessionsController < ApplicationController

  def new
    @title = 'Sign In'
  end

  def create
    user = User.find_by(email: params[:session][:ident]) ||
           User.find_by(cell_number: params[:session][:ident])
    if user && user.authenticate(params[:session][:password])
      redirect_to user
    end
  end

end
