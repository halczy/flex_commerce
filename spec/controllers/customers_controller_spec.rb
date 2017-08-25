require 'rails_helper'

RSpec.describe CustomersController, type: :controller do

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
        expect(response).to redirect_to(customer_path(Customer.last))
        expect(assigns(:customer).email).to eq('ident_customer@example.com')
      end

      it 'can identify when customer enter a cell number' do
        post :create, params: { customer: { ident: '17612345678',
                                            password: 'example',
                                            password_confirmation: 'example' } }
        expect(response).to redirect_to(customer_path(Customer.last))
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
        before do
          post :create, params: { customer: { email: 'customer@creation.com',
                                              cell_number: '14900000000',
                                              name: 'Customer Create Test',
                                              password: 'example',
                                              password_confirmation: 'example' } }
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

end
