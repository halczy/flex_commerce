require 'rails_helper'

RSpec.describe CustomersController, type: :controller do

  let(:customer) { FactoryGirl.create(:customer) }

  describe 'GET new' do
    it "renders the new customer sign up template" do
      get :new
      expect(response).to render_template(:new)
      expect(assigns(:customer)).to be_a_new(Customer)
    end
  end

  describe 'POST create' do
    context 'customer identifier' do
      it 'can identify when customer enter an email' do
        post :create, params: { customer: { ident: 'ident_customer@example.com',
                                            password: 'example',
                                            password_confirmation: 'example' } }
        expect(response).to redirect_to(dashboard_path(Customer.last))
        expect(assigns(:customer).email).to eq('ident_customer@example.com')
      end

      it 'can identify when customer enter a cell number' do
        post :create, params: { customer: { ident: '17612345678',
                                            password: 'example',
                                            password_confirmation: 'example' } }
        expect(response).to redirect_to(dashboard_path(Customer.last))
        expect(assigns(:customer).cell_number).to eq('17612345678')
      end

      it 'does not allow user to create account by member id' do
        post :create, params: { customer: { ident: '123456',
                                            password: 'example',
                                            password_confirmation: 'example' } }
        expect(response).to render_template(:new)
      end

      it 'catches invalid ident' do
        post :create, params: { customer: { ident: 'i23ji4of3',
                                            password: '',
                                            password_confirmation: '' } }
        expect(response).to render_template(:new)
      end

      it 'catches empty ident' do
        post :create, params: { customer: { ident: '' }}
        expect(response).to render_template(:new)
      end
    end

    describe 'customer creation' do
      context 'with valid params' do
        before do |example|
          if example.metadata[:create_cart]
            session[:cart_id] = FactoryGirl.create(:cart).id
          end

          if example.metadata[:with_ref]
            post :create, params: {
              customer: {
                email: 'customer@creation.com',
                cell_number: '14900000000',
                name: 'Customer Create Test',
                referer_id: customer.id,
                password: 'example',
                password_confirmation: 'example'
              }
            }
          else
            post :create, params: {
              customer: {
                email: 'customer@creation.com',
                cell_number: '14900000000',
                name: 'Customer Create Test',
                password: 'example',
                password_confirmation: 'example'
              }
            }
          end
        end

        it 'creates customer with correct attributes' do
          expect(assigns(:customer).email).to eq('customer@creation.com')
          expect(assigns(:customer).cell_number).to eq('14900000000')
          expect(assigns(:customer).name).to eq('Customer Create Test')
        end

        it 'creates customer using customer class' do
          expect(assigns(:customer).type).to eq('Customer')
          expect(assigns(:customer).customer?).to be_truthy
        end

        it 'cleans up session cart_id', create_cart: true do
          expect(session[:cart_id]).to be_nil
        end

        it 'sets reffral if referer_id is provided', with_ref: true do
          expect(assigns(:customer).referer).to be_an_instance_of Customer
        end
      end

      context 'with invalid params' do
        it 'raise an error when incorrect required params is given' do
          expect do
            post :create, params: { user: { email: 'cus@creation.com',
                                            password: 'example',
                                            password_confirmation: 'example' } }
          end.to raise_error(NoMethodError)
        end

        it 'does not allow customer to make themself admin' do
          post :create, params: { customer: { email: 'cus@creation.com',
                                              type: 'Admin',
                                              password: 'example',
                                              password_confirmation: 'example' } }
          expect(assigns(:customer).type).not_to eq('Admin')
        end
      end
    end
  end

  describe 'GET show' do
    let(:customer)       { FactoryGirl.create(:customer) }
    let(:other_customer) { FactoryGirl.create(:customer) }
    let(:admin)          { FactoryGirl.create(:admin) }

    it 'renders show page for signed in customer' do
      signin_as(customer)
      get :show, params: { id: customer.id }
      expect(response).to render_template(:show)
    end

    describe 'access control' do
      it 'requires customer to be signed in' do
        get :show, params: { id: customer.id }
        expect(response).to redirect_to(signin_path)
      end

      it 'only allows customer to see their own profile' do
        signin_as(other_customer)
        get :show, params: { id: customer.id }
        expect(response).to redirect_to(root_url)
      end

      it 'allows admin to access any customer profile' do
        signin_as(admin)
        get :show, params: { id: customer.id }
        expect(response).to render_template(:show)
      end
    end
  end

  describe 'GET edit' do
    before { signin_as customer }

    it 'responses successfully' do
      get :edit, params: { id: customer.id }
      expect(response).to be_success
    end
  end

  describe 'POST update' do
    before { signin_as customer }

    context 'with valid params' do
      it 'updates customer record' do
        patch :update, params: { id: customer.id, customer: {name: 'New Name'} }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(customer)
        expect(customer.reload.name).to eq('New Name')
      end

      it 'updates customer password' do
        patch :update, params: {
          id: customer.id,
          customer: {
            password: 'acbdefg123456',
            password_confirmation: 'acbdefg123456'
          }
        }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(customer)
      end

      it 'sets customer referer if not set previously' do
        new_customer = FactoryGirl.create(:customer)
        patch :update, params: {
          id: customer.id,
          customer: {
            referer_id: new_customer.id
          }
        }
        expect(customer.referer).to eq(new_customer)
      end

      it 'updates customer financial information' do
        patch :update, params: {
          id: customer.id,
          customer: {
            alipay_account: 'alipay@test.com',
            bank_account: '6212123412341234',
            bank_name: 'ACME Bank',
            bank_branch: 'ABCD'
          }
        }
        customer.reload
        expect(customer.alipay_account).to eq('alipay@test.com')
        expect(customer.bank_account).to eq('6212123412341234')
        expect(customer.bank_name).to eq('ACME Bank')
        expect(customer.bank_branch).to eq('ABCD')
      end
    end

    context 'with invalid params' do
      it 'rejects change to referer is set previously' do
        old_referer = FactoryGirl.create(:customer)
        new_referer = FactoryGirl.create(:customer)
        Referral.create!(referer: old_referer, referee: customer)
        patch :update, params: {
          id: customer.id,
          customer: {
            referer_id: new_referer.id
          }
        }
        expect(customer.referer).to eq(old_referer)
      end

      it 'rejects invalid params' do
        patch :update, params: {
          id: customer.id,
          customer: {
            cell_number: '1234560',
            email: 'abcd#sadfadsf',
            password: '1',
            password_confirmation: '1'
          }
        }
        expect(response).to render_template(:edit)
      end
    end
  end

end
