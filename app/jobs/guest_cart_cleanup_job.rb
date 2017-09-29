class GuestCartCleanupJob < ApplicationJob
  queue_as :default

  def perform
    carts = Cart.where(user_id: nil).where("created_at <= ?", 1.day.ago)
    carts.each do |cart|
      cart.inventories.each { |inv| inv.restock } unless cart.inventories.empty?
      cart.destroy
    end
  end
end
