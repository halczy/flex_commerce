class Admin::GeosController < Admin::AdminController

  def index
    @inventories = Inventory.all
  end

end
