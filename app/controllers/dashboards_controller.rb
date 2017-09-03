class DashboardsController < UsersController
  # Filters
  before_action :authenticate_user
  before_action :set_user

  def show
  end

end
