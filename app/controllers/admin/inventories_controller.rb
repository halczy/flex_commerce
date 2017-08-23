class Admin::InventoriesController < Admin::AdminController

  def index
    params[:status] ||= ""
    inventories = Inventory.try(params[:status].to_sym) || Inventory.all
    inventories = inventories.order(updated_at: :desc)
    @inventories = inventories.page params[:page]
  end

end
