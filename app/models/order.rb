class Order < ApplicationRecord
  include TranslateEnum
  
  # Relationships
  belongs_to :user
  has_one   :address, as: :addressable
  has_many  :inventories
  has_many  :orders
  has_many  :products,         -> { distinct }, through: :inventories
  has_many  :shipping_methods, -> { distinct }, through: :inventories
  has_many  :payments
  has_many  :transactions, as: :transactable
  accepts_nested_attributes_for :products

  # Validation
  monetize :shipping_cost_cents, numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  after_initialize :load_shipment
  after_touch      :load_shipment

  # Enum
  enum status: {
    # Creation
    created: 0, shipping_confirmed: 10, confirmed: 20,
    # Payment
    payment_pending: 30, partial_payment: 40, payment_fail: 50,
    # Service
    payment_success: 60, staff_confirmed: 70, pickup_pending: 80, shipped: 90,
    completed: 100
  }
  translate_enum :status

  # Scope
  scope :creation_process, -> (user) { user.orders.where(status: 0..20) }
  scope :payment_process,  -> (user) { user.orders.where(status: 30..50) }
  scope :service_process,  -> (user) { user.orders.where(status: 60..100) }

  # Attributes
  attribute :shipping_company
  attribute :tracking_number
  attribute :shipped_at
  attribute :shipping_completed_at
  attribute :pickup_readied_at
  attribute :pickup_completed_at

  def inventories_by(product)
    inventories.where(product: product)
  end

  def pick_up_address
    invs = inventories.select { |i| i.shipping_method.variety == 'self_pickup' }
    invs.sample.shipping_method.address
  end

  def shipping_method_mix
    varieties = []
    inventories.each do |inv|
      return false unless inv.shipping_method
      varieties << inv.shipping_method.variety
    end
    varieties.uniq!
    varieties.length == 1 ? varieties[0] : 'mix'
  end

  def pre_confirm_total
    return false unless shipping_confirmed?
    order_service = OrderService.new(order_id: id)
    invs_cost = inventories.sum { |i| i.product.price_member }
    order_service.total_shipping_cost + invs_cost
  end

  def total
    return false unless status_before_type_cast >= 20
    order_service = OrderService.new(order_id: id)
    order_service.total_shipping_cost + order_service.total_inventories_cost
  end

  def amount_paid
    payments.sum do |payment|
      if payment.status_before_type_cast >= 20 && payment.charge? 
        payment.amount
      else
        0
      end
    end
  end

  def amount_unpaid
    total ? total - amount_paid : pre_confirm_total - amount_paid
  end

  def destroyable?
    status_before_type_cast <= 20
  end

  def cancel
    return false unless destroyable?
    inventories.each(&:restock)
    destroy
  end

  private

    def load_shipment
      shipment.each do |key, value|
        send("#{key}=", value)
      end
    end
end
