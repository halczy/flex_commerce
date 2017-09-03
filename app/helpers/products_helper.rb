module ProductsHelper

  def build_product_breadcrumb(product)
    breadcrumb = []
    if product.categories.brand.present?
      brand = product.categories.brand.first
      name = brand.name
      link = url_for(brand)
      breadcrumb << [name, link]
    end
    breadcrumb
  end

end
