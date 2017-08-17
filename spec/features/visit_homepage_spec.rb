require 'rails_helper'

describe 'visit homepage as guest' do
  it 'renders sign in and sign up when not signed in' do
    visit root_path
    expect(page).to have_content('Sign In')
    expect(page).to have_content('Sign Up')
  end

  context 'fault tolerant' do
    let(:customer) { FactoryGirl.create(:customer) }

    before do
      visit signin_path
      fill_in 'session[ident]', with: customer.email
      fill_in 'session[password]', with: 'example'
      check('session[remember_me]')
      click_button 'Submit'
    end

    it 'does not generate error when session user_id is invalid' do
      User.delete(customer)
      visit root_path
      expect(page).to have_content('Sign In')
    end
  end
end

describe 'frontpage displays feature products' do
  before do
    feature_cat = FactoryGirl.create(:feature)
    @product_1 = FactoryGirl.create(:product)
    FactoryGirl.create(:image, imageable_type: 'Product', imageable_id: @product_1.id)
    @product_2 = FactoryGirl.create(:product)
    Categorization.create(category: feature_cat, product: @product_1)
    Categorization.create(category: feature_cat, product: @product_2)
    Image.create(title: "Placeholder Image",
                 in_use: true,
                 source_channel: 0,
                 image: Rack::Test::UploadedFile.new(File.join(
                          Rails.root, 'public', 'placeholder_img',
                          'no-image-slide.png'), 'image/png'))
  end

  it 'shows feature products' do
    visit root_path

    expect(page).to have_content('Feature Products')
    expect(page).to have_content(@product_1.name)
    expect(page).to have_content(@product_2.name)
    expect(page).to have_content('Detail', count: 2)
    expect(page).to have_content('Add to Cart', count: 2)
  end
end
