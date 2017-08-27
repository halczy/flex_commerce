class Cart < ApplicationRecord
  # Relationships
  belongs_to :user, optional: true
  has_many :inventories

  # Scope / Enum
  enum status: { inactive: 0, active: 1, inv_removed: 2 }

  def add(product, quantity = 1)
    inventories = product.inventories.available.limit(quantity.to_i)
    if inventories.count == quantity
      inventories.update(cart_id: id, status: 1)
    end
  end

  def migrate_to(user)
    return true if inventories.empty?
    user_cart = Cart.find_or_create_by(user: user)
    transfer_invs_to(user_cart)
  end

  def transfer_invs_to(target_cart)
    inventories.update(cart: target_cart)
  end
end
