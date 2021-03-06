class Inventory < ApplicationRecord
  include TranslateEnum
  
  # Relationships
  belongs_to :product, touch: true
  belongs_to :user,            optional: true, touch: true
  belongs_to :cart,            optional: true, touch: true
  belongs_to :order,           optional: true
  belongs_to :shipping_method, optional: true

  # Validations
  monetize :purchase_price_cents, numericality: { greater_than_or_equal_to: 0 }

  # Scope | Enum
  scope :available,     -> { where(status: 0) }
  scope :unavailable,   -> { where.not(status: 0) }
  scope :destroyable,   -> { where("status <= ?", 2) }
  scope :undestroyable, -> { where("status >= ?", 3) }

  enum status: { unsold: 0,
                 in_cart: 1,
                 in_order: 2,
                 in_checkout: 3,
                 sold: 4,
                 returned: 5 }
  translate_enum :status

  def restock
    raise(StandardError, "Inventory Locked!") unless status_before_type_cast <= 2
    update(cart: nil, order: nil, user: nil,
           status: 0, shipping_method: nil, purchase_weight: nil,
           purchase_price: nil)
  end
end
