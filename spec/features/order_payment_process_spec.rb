require 'rails_helper'

describe 'customer order payment process', type: :feature do
  let(:customer) { FactoryGirl.create(:customer) }

  before do
    feature_signin_as customer
    @product = FactoryGirl.create(:product, purchase_ready: true)
    @province = Geo.find(@product.shipping_methods.delivery.first.shipping_rates
                                 .first.geo_code)
    visit product_path(@product)
    click_on 'Add to Cart'
    click_on 'Checkout'
    select 'Delivery', from: 'order_products_attributes_0_shipping_methods'
    click_on 'Next'
    fill_in 'address[recipient]', with: 'Test Recipient'
    fill_in 'address[contact_number]', with: '17612344321'
    fill_in 'address[name]', with: 'Home'
    select @province.name, from: 'provinces_select'
    fill_in 'address[street]', with: 'Test Street Address'
    click_on 'Next'
  end

  context 'confirm order' do
    it 'confrims order and redirect to payment page' do
      click_on 'Confirm Order'

      expect(page).to have_content('Payment Summary')
      expect(page).to have_content('Amount Paid: ¥0')
      expect(page).to have_content('Order Status: Confirmed')
    end
  end

  context 'pay via wallet' do
    before { click_on 'Confirm Order' }

    it 'has disabled wallet payment button if customer has no wallet balance' do
      expect(page).to have_button('Pay with Wallet', disabled: true)
    end

    it 'has enabled wallet payment button if customer has wallet balance' do
      Order.last.user.wallet.update(balance: 1)
      visit payment_order_path(Order.last)
      expect(page).to have_button('Pay with Wallet')
    end

    it 'pays the full order amount by default' do
      Order.last.user.wallet.update(balance: 999_999)
      visit payment_order_path(Order.last)
      click_on 'Pay with Wallet'

      expect(page).to have_content('Successful Payment')
      expect(page).to have_content('Order Status Payment Success')
      expect(page).to have_content('Payment Type Charge')
      expect(page).to have_content('Payment Processor Wallet')
    end

    it 'can pay a custom amount' do
      Order.last.user.wallet.update(balance: 100)
      visit payment_order_path(Order.last)

      fill_in 'custom_amount', with: '1'
      click_on 'Pay with Wallet'

      expect(page.current_path).to eq(payment_order_path(Order.last))
      expect(page).to have_content('Partial Payment')
      expect(page).to have_content('Amount Paid: ¥1')
    end

    it 'can pay an order in installments' do
      Order.last.user.wallet.update(balance: 99999999)
      visit payment_order_path(Order.last)

      fill_in 'custom_amount', with: '1'
      click_on 'Pay with Wallet'
      fill_in 'custom_amount', with: Order.last.amount_unpaid.to_s
      click_on 'Pay with Wallet'

      expect(page).to have_content('Successful Payment')
      expect(page).to have_content('Order Status Payment Success')
      expect(page).to have_content('Payment Type Charge')
      expect(page).to have_content('Payment Processor Wallet')
    end

    it 'rejects negative custom amount' do
      Order.last.user.wallet.update(balance: 99999999)
      visit payment_order_path(Order.last)

      fill_in 'custom_amount', with: '-100'
      click_on 'Pay with Wallet'

      expect(page).to have_content('Invalid payment amount')
    end

    it 'rejects zero custom amount' do
      Order.last.user.wallet.update(balance: 99999999)
      visit payment_order_path(Order.last)

      fill_in 'custom_amount', with: '0'
      click_on 'Pay with Wallet'

      expect(page).to have_content('Invalid payment amount')
    end
  end

  context 'pay via alipay' do
  end
end
