class Order < ApplicationRecord
  # Relationships
  belongs_to :user
  has_one    :shipping_method
  has_one    :address, as: :addressable
  has_many   :inventories
  has_many   :products, -> { distinct }, through: :inventories
  accepts_nested_attributes_for :products

  # Enum
  enum status: {
    # Creation
    created: 0, shipping_confirmed: 10, customer_confirmed: 20,
    # Payment
    payment_pending: 30, partial_payment: 40, payment_fail: 50,
    payment_success: 60,
    # Service
    staff_confirmed: 70, pickup_pending: 80, shipped: 90, completed: 100
  }

  # Virtual Attributes
  attribute :shipping_method, :string

end
