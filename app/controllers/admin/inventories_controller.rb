class Admin::InventoriesController < Admin::AdminController
  # Filter
  before_action :set_inventory, only: [:show, :destroy]
  before_action :smart_return, only: [:destroy]

  def index
    status = params[:status] ||= ""
    inventories = Inventory.try(status) || Inventory.all
    inventories = inventories.order(updated_at: :desc)
    @inventories = inventories.page params[:page]
  end

  def show
  end

  def destroy
    if @inventory.status_before_type_cast < 3
      @inventory.destroy
      flash[:success] = t('.success')
      redirect_back_or admin_inventories_path
    else
      flash[:danger] = t('.danger')
      redirect_to admin_inventory_path(@inventory)
    end
  end

  private

    def set_inventory
      @inventory = Inventory.find(params[:id])
    end

end
