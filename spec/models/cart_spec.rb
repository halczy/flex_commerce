require 'rails_helper'

RSpec.describe Cart, type: :model do

  let(:cart)      { FactoryGirl.create(:cart) }
  let(:product)   { FactoryGirl.create(:product) }
  let(:inventory) { FactoryGirl.create(:inventory) }
  let(:customer)  { FactoryGirl.create(:customer) }

  describe 'creation' do
    it 'can be created' do
      expect(cart).to be_valid
    end
  end

  describe 'add product inventory' do

    before do |example|
      unless example.metadata[:skip_before]
        @product = product
        3.times { FactoryGirl.create(:inventory, product: @product) }
      end
    end

    it 'adds one inventory to cart and update its status' do
      expect(cart.add(@product)).to be_truthy
      expect(cart.inventories.count).to eq(1)
      expect(@product.inventories.available.count).to eq(2)
      expect(cart.inventories.first.status).to eq('in_cart')
    end

    it 'adds multiple inventory to cart' do
      expect(cart.add(@product, 3)).to be_truthy
      expect(cart.inventories.count).to eq(3)
      expect(@product.inventories.available.count).to eq(0)
      expect(cart.inventories.sample.status).to eq('in_cart')
    end

    it 'returns false if product is out of stock', skip_before: true do
      expect(cart.add(product)).to be_falsey
      expect(cart.inventories).to be_empty
    end

    it 'returns false if product does not have enough stock' do
      expect(cart.add(@product, 100)).to be_falsey
      expect(cart.inventories).to be_empty
      expect(@product.inventories.available.count).to eq(3)
    end
  end

  describe 'migrate session cart to user cart' do
    it 'returns true if session cart is empty' do
      existing_user_cart = FactoryGirl.build_stubbed(:cart, user: customer)
      expect(cart.migrate_to(customer)).to be_truthy
      expect(existing_user_cart).not_to be_changed
    end

    it 'creates a user cart and transfer inventories' do
      session_cart = FactoryGirl.create(:cart)
      3.times { FactoryGirl.create(:inventory, cart: session_cart) }
      expect(customer.cart).to be_nil
      expect(session_cart.migrate_to(customer)).to be_truthy
      expect(customer.cart).to be_truthy
      expect(customer.cart.inventories.count).to eq(3)
    end

    it 'transfer inventories to existing user cart with inventories' do
      session_cart = FactoryGirl.create(:cart)
      user_cart = FactoryGirl.create(:cart, user: customer)
      2.times { FactoryGirl.create(:inventory, cart: session_cart) }
      3.times { FactoryGirl.create(:inventory, cart: user_cart) }
      expect(session_cart.migrate_to(customer)).to be_truthy
      expect(customer.cart.inventories.count).to eq(5)
    end
  end

  describe 'shopping cart display methods' do

    before do |example|
      unless example.metadata[:skip_before]
        @cart = cart
        @product_1 = FactoryGirl.create(:product)
        @product_2 = FactoryGirl.create(:product)
        2.times { FactoryGirl.create(:inventory, cart: @cart, product: @product_1 ) }
        4.times { FactoryGirl.create(:inventory, cart: @cart, product: @product_2 ) }
        3.times { FactoryGirl.create(:inventory, cart: @cart) }
      end
    end

    context '#products' do
      it 'returns an array of products in cart' do
        expect(@cart.products.count).to eq(5)
      end
    end

    context '#product_inventories' do
      it 'returns the selected product inventories in cart' do
        expect(@cart.product_inventories(@product_1).count).to eq(2)
        expect(@cart.product_inventories(@product_2).count).to eq(4)
      end
    end

    context '#inventories_by' do
      it 'returns the selected product inventories in cart' do
        expect(@cart.inventories_by(@product_1).count).to eq(2)
        expect(@cart.inventories_by(@product_2).count).to eq(4)
      end
    end

    context '#price_subtotal' do
      it 'returns the selected product subtotal' do
        expect(@cart.price_subtotal(@product_1)).to eq(@product_1.price_member * 2)
        expect(@cart.price_subtotal(@product_2)).to eq(@product_2.price_member * 4)
      end
    end

    context '#price_total', skip_before: true do
      it 'returns the total price of all products in cart' do
        product_1 = FactoryGirl.create(:product, price_member: 11)
        product_2 = FactoryGirl.create(:product, price_member: 22)
        2.times { FactoryGirl.create(:inventory, cart: cart, product: product_1 ) }
        4.times { FactoryGirl.create(:inventory, cart: cart, product: product_2 ) }
        expect(cart.price_total.to_i).to eq(110)
      end
    end
  end

end
