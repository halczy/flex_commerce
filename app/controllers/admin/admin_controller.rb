class Admin::AdminController < ApplicationController
  # Filter
  before_action :authenticate_user
  before_action :authenticate_admin
end
