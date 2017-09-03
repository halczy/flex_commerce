require 'rails_helper'

RSpec.describe "Friendly Forwarding", type: :request do

  let(:admin)    { FactoryGirl.create(:admin) }
  let(:customer) { FactoryGirl.create(:customer) }

  it 'stores request location in session' do
    get "/customers/#{customer.id}"
    expect(session[:forwarding_url]).to include("/customers/#{customer.id}")
  end

  it 'redirects back to previous location after sign in' do
    get "/admin/products"
    expect(response).to redirect_to(signin_path)

    post "/sessions", params: { session: { ident: admin.email, password: 'example' } }
    expect(response).to redirect_to(admin_products_path)
  end

  it 'redirects to default location customer sign in unprompted' do
    get "/signin"
    post "/sessions", params: { session: { ident: customer.email, password: 'example' } }
    expect(response).to redirect_to(dashboard_path(customer))
  end

  it 'redirects to default location when admin sign in unprompted' do
    get "/signin"
    post "/sessions", params: { session: { ident: admin.email, password: 'example' } }
    expect(response).to redirect_to(admin_dashboard_index_path)
  end

end
