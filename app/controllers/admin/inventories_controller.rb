class Admin::InventoriesController < Admin::AdminController
  # Filter
  before_action :set_inventory, only: [:show]

  def index
    params[:status] ||= ""
    inventories = Inventory.try(params[:status].to_sym) || Inventory.all
    inventories = inventories.order(updated_at: :desc)
    @inventories = inventories.page params[:page]
  end

  def show
  end

  private

    def set_inventory
      @inventory = Inventory.find(params[:id])
    end



end
