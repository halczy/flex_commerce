require 'rails_helper'

RSpec.describe GuestCartCleanupJob, type: :job do

  before do
    ActiveJob::Base.queue_adapter = :test
    @empty_cart = FactoryBot.create(:cart, created_at: 2.weeks.ago)
    @cart_with_invs = FactoryBot.create(:cart, created_at: 3.week.ago)
    3.times { @cart_with_invs.inventories << FactoryBot.create(:inventory) }
    @user_cart = FactoryBot.create(:user_cart)
  end

  describe "#perform_later" do
    it 'adds job to queue' do
      expect {
        GuestCartCleanupJob.perform_later
      }.to have_enqueued_job
    end

    it 'cleans up old empty carts' do
      GuestCartCleanupJob.perform_now
      expect(Cart.all).not_to include(@empty_cart)
    end

    it 'cleans up guest cart with inventories' do
      GuestCartCleanupJob.perform_now
      expect(Cart.all).not_to include(@cart_with_invs)
      expect(Inventory.all.sample.cart).to be_nil
    end

    it 'leaves user cart alone' do
      GuestCartCleanupJob.perform_now
      expect(Cart.all).to include(@user_cart)
    end

    it 'leaves fresh empty cart alone' do
      fresh_cart = FactoryBot.create(:cart)
      GuestCartCleanupJob.perform_now
      expect(Cart.all).to include(fresh_cart)
    end
  end



end
