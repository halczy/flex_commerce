require 'rails_helper'

describe 'withdraw from wallet', type: :feature do

  let(:customer) { FactoryGirl.create(:customer) }
  let(:admin)    { FactoryGirl.create(:admin) }
  let(:bank_transfer) { FactoryGirl.create(:bank_transfer) }

  before { feature_signin_as customer }

  context 'withdraw to bank' do
    context 'with valid condition' do
      before do
        customer.update(settings: { bank_account: '12345679', bank_name: '123' })
        customer.wallet.update(balance: 150.to_money, withdrawable: 150.to_money)
      end

      it 'can create bank withdraw' do
        visit wallet_path(customer)
        click_on 'New Withdraw'
        fill_in 'amount', with: '50'
        click_on 'Submit Withdraw'

        expect(page).to have_content('Amount ¥50')
        expect(page).to have_content('Current Status Pending')
        expect(page).to have_content('Withdraw To Bank')
        expect(page).to have_content(customer.bank_account)
      end

      it 'can let admin confirm bank withdraw' do
        visit wallet_path(customer)
        click_on 'New Withdraw'
        fill_in 'amount', with: '50'
        click_on 'Submit Withdraw'
        feature_signin_as admin
        click_on 'Transfers'
        click_on 'Detail'
        click_on 'Approve Transfer'
        click_on 'Confirm Transferred'
        expect(page).to have_content('Status Success')

        feature_signin_as customer
        visit wallet_path(customer)
        click_on 'Withdraw List'
        click_on "#{Transfer.last.id}"
        expect(page).to have_content('Current Status Success')
      end
    end

    context 'with invalid condition' do
      it 'redirects to profile edit page if customer does not have bank account' do
        visit wallet_path(customer)
        click_on 'New Withdraw'

        expect(page.current_path).to eq(edit_customer_path(customer))
      end

      it 'cannot withdraw more than withdrawable' do
        customer.update(settings: { bank_account: '12345679', bank_name: '123' })
        customer.wallet.update(balance: 150.to_money, withdrawable: 150.to_money)
        visit wallet_path(customer)
        click_on 'New Withdraw'
        fill_in 'amount', with: '12345679'
        click_on 'Submit Withdraw'

        expect(page).to have_content('Unable to initialize transfer request.')
      end
    end
  end

  context 'withdraw to Alipay' do
    before do
      customer.update(settings: { alipay_account: 'user@alipay.com' })
      customer.wallet.update(balance: 150.to_money, withdrawable: 150.to_money)
    end

    it 'can create alipay withdraw' do
      visit wallet_path(customer)
      click_on 'New Withdraw'
      fill_in 'amount', with: '50'
      click_on 'Submit Withdraw'

      expect(page).to have_content('Amount ¥50')
      expect(page).to have_content('Current Status Pending')
      expect(page).to have_content('Withdraw To Alipay')
      expect(page).to have_content(customer.alipay_account)
    end

    it 'lets admin process alipay withdraw automatically' do
      visit wallet_path(customer)
      click_on 'New Withdraw'
      fill_in 'amount', with: '50'
      click_on 'Submit Withdraw'

      stub_request(:post, "https://openapi.alipaydev.com/gateway.do").
        to_return(body: {
          alipay_fund_trans_toaccount_transfer_response: {
            code: '10000',
            out_biz_no: Transfer.last.id,
            order_id: '1234567890'
          }
        }.to_json, status: 200)

      feature_signin_as admin
      click_on 'Transfers'
      click_on 'Detail'
      click_on 'Approve Transfer'
      click_on 'Automatic Transfer'
      expect(page).to have_content('Status Success')

      feature_signin_as customer
      visit wallet_path(customer)
      click_on 'Withdraw List'
      click_on "#{Transfer.last.id}"
      expect(page).to have_content('Current Status Success')
    end

    it 'lets admin process aliapy withdraw manually' do
      visit wallet_path(customer)
      click_on 'New Withdraw'
      fill_in 'amount', with: '50'
      click_on 'Submit Withdraw'
      feature_signin_as admin
      click_on 'Transfers'
      click_on 'Detail'
      click_on 'Approve Transfer'
      click_on 'Manual Transfer'
      expect(page).to have_content('Status Success')

      feature_signin_as customer
      visit wallet_path(customer)
      click_on 'Withdraw List'
      click_on "#{Transfer.last.id}"
      expect(page).to have_content('Current Status Success')
    end
  end
end
