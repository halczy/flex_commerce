class Admin::CategoriesController < ApplicationController
  before_action :authenticate_user
  before_action :authenticate_admin

  def index
    @title = 'Categories'
  end

end
