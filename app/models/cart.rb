class Cart < ApplicationRecord
  # Relationships
  belongs_to :user, optional: true
  has_many :inventories
  has_many :products, -> { distinct }, through: :inventories

  # Scope / Enum
  enum status: { inactive: 0, active: 1, inv_removed: 2 }

  def add(product, quantity = 1)
    inventories = product.inventories.available.limit(quantity.to_i)
    if inventories.count == quantity
      inventories.update(cart_id: id, status: 1)
    elsif !product.strict_inventory
      product.add_inventories(quantity - inventories.count)
      inventories.update(cart_id: id, status: 1)
    end
  end

  def remove(product, quantity = 0)
    invs = quantity(product)
    invs = invs.limit(quantity) if quantity > 0
    invs.each { |inv| inv.update(cart_id: nil, status: 0) }
  end

  def migrate_to(user)
    return true if inventories.empty?
    user_cart = Cart.find_or_create_by(user: user)
    transfer_invs_to(user_cart)
  end

  def transfer_invs_to(target_cart)
    inventories.update(cart: target_cart)
  end

  def quantity(product)
    inventories.where(product: product)
  end

  def inventories_diff(product, target_quantity)
    current_invs_count = quantity(product).count
    target_quantity - current_invs_count
  end

  def inventories_by(object)
    inventories.where(object.class.name.downcase => object)
  end

  def subtotal(product)
    quantity(product).count * product.price_member
  end

  def total
    products.inject(0) {|sum, product| sum + subtotal(product) }
  end

end
