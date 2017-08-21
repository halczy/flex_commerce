class Admin::InventoriesController < Admin::AdminController

  def products_view
    case params[:inv_status]
    when 'in_stock'
      products = Product.in_stock.distinct
    when 'out_of_stock'
      products = Product.out_of_stock.distinct
    else
      products = Product.all
    end  
    
    @products = products.page params[:page]
  end

end
