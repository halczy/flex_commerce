class Admin::InventoriesController < Admin::AdminController
  # Filter
  before_action :set_inventory, only: [:show, :destroy]

  def index
    params[:status] ||= ""
    inventories = Inventory.try(params[:status].to_sym) || Inventory.all
    inventories = inventories.order(updated_at: :desc)
    @inventories = inventories.page params[:page]
  end

  def show
  end

  def destroy
    if @inventory.status_before_type_cast < 3
      @inventory.destroy
      flash[:success] = "Successfully deleted inventory."
      redirect_to admin_inventories_path
    else
      flash[:danger] = "This inventory cannot be deleted."
      redirect_to admin_inventory_path(@inventory)
    end
  end

  private

    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

end
