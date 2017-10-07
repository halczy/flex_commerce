require 'rails_helper'

RSpec.describe Admin::WalletsController, type: :controller do

  let(:admin)    { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }


  describe 'POST deposit' do
    context 'with valid params' do
      before { signin_as admin }

      it 'creates and executes a transfer' do
        expect { post :deposit, params: {
          transferer_id: admin.id,
          transferee_id: customer.id,
          amount: 150
          }
        }.to change(Transfer, :count).by(1)
        expect(customer.wallet.reload.balance).to eq(Money.new(15000))
      end

      it 'redirects to customer profile' do
        post :deposit, params: {
          transferer_id: admin.id, transferee_id: customer.id, amount: 300
        }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admin_customer_path(customer.id))
      end
    end

    context 'with invalid params' do
      it 'does not allow unsigned in visitor to depsit to account' do
        post :deposit, params: {
          transferer_id: admin.id, transferee_id: customer.id, amount: 300
        }
        expect(response).to redirect_to(signin_path)
      end

      it 'does not allow customer to deposit using this action' do
        signin_as customer
        post :deposit, params: {
          transferer_id: admin.id, transferee_id: customer.id, amount: 300
        }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
