require 'rails_helper'

RSpec.describe Product, type: :model do

  let(:product) { FactoryGirl.create(:product) }

  describe 'creation' do
    it 'can be created' do
      expect(product).to be_valid
    end
  end

  describe 'validation' do
    it 'requires product to have a name' do
      no_name = FactoryGirl.build(:product, name: nil)
      no_name.valid?
      expect(no_name.errors.messages[:name]).to be_present
    end

    it 'requires product name to be shorter than 31 characters' do
      long_name = FactoryGirl.build(:product, name: "#{'x' * 31}")
      long_name.valid?
      expect(long_name.errors.messages[:name]).to be_present
    end

    it 'requires product to have a positive value' do
      neg_price_market = FactoryGirl.build(:product, price_market_cents: -100)
      neg_price_market.valid?
      expect(neg_price_market.errors.messages[:price_market]).to be_present
    end
  end

  describe '#extract_images' do
    intro = '<a href=\"/uploads/store/a1350f1dca616cc4f8dca4f46c136c54.jpeg\"'
    desc = 't;/uploads/store/a1350f1dca616cc4f8dca4f46c136c54.jpgpe=\"image/jpeg\"'
    spec = '<img src=\"/uploads/store/123.png\"> <img src=\"/uploads/store/789.png\">'

    let(:prod_image_1) { FactoryGirl.create(:product, description: desc) }
    let(:prod_image_3) { FactoryGirl.create(:product, introduction: intro,
                                                      description: desc,
                                                      specification: spec) }

    it 'populations an array of image file name' do
      expect(prod_image_1.send(:extract_images).count).to eq(1)
      expect(prod_image_3.send(:extract_images).count).to eq(4)
    end

    it 'returns an empty array if no images are found' do
      expect(product.send(:extract_images)).to eq([])
    end
  end

  describe '#result_cleanup' do
    it 'removes empty and flatten arrays' do
      result = product.send(:result_cleanup, [["abcd.jpg", "123.png"], [], []])
      expect(result).to eq(["abcd.jpg", "123.png"])
    end

    it 'removes extra slash in filename' do
      result = product.send(:result_cleanup, ['/123.png', "/abc.jpeg"])
      expect(result).to eq(['123.png', 'abc.jpeg'])
    end
  end

  context 'image association' do
    before do
      @img_1 = FactoryGirl.create(:image)
      @img_2 = FactoryGirl.create(:image)
      @unrelated_img_3 = FactoryGirl.create(:image)
      desc = "/" + @img_1.image[:fit].data['id']
      spec = "/" + @img_2.image[:fit].data['id']
      @product = FactoryGirl.create(:product, description: desc,
                                              specification: spec)
    end

    describe '#associate_images' do
      it 'associates images with product' do
        @product.associate_images
        expect(@product.images).to match_array([@img_1, @img_2])
      end

      it 'logs the source channel as editor' do
        @product.associate_images
        expect(@product.images.first.source_channel).to eq('editor')
      end

      it 'does not associate unrelated images' do
        @product.associate_images
        expect(@product.images).not_to include(@unrelated_img_3)
      end
    end

    describe '#unassociate_images' do
      it 'unassociate products images' do
        @product.associate_images
        @product.unassociate_images
        expect(@product.reload.images).to be_empty
      end
    end
  end

  describe '#cover_image' do
    it 'reutrns a cover image' do
      image = FactoryGirl.create(:image, imageable_type: 'Product', imageable_id: product.id)
      expect(product.cover_image).to eq(image)
    end

    it 'returns a placeholder image when no product image is available' do
      expect(product.cover_image).to eq(Image.placeholder.first)
    end
  end

  describe '#destroy' do
    context 'deletable product' do
      it 'destroy itself' do
        product.destroy
        expect{product.reload}.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not remove associated categories on destroy' do
        3.times do
          product.categorizations.create(category: FactoryGirl.create(:category))
        end
        product.destroy
        expect(Categorization.count).to eq(0)
        expect(Category.count).to eq(3)
      end

      it 'removes attached images on destroy' do
        3.times do
          FactoryGirl.create(:image, imageable_type: 'Product',
                                     imageable_id: product.id)
        end
        product.destroy
        expect(Image.count).to eq(0)
      end
    end
  end

  describe 'inventory management' do
    context 'add' do
      describe '#add_inventory' do
        it 'creates one inventory for product' do
          product.send(:add_inventory)
          inventory = product.inventories.first
          expect(product.inventories.count).to eq(1)
          expect(inventory).to be_an_instance_of(Inventory)
        end
      end

      describe '#add_inventories' do
        it 'creates multiple inventories for product' do
          product.add_inventories(10)
          expect(product.inventories.count).to eq(10)
        end

        it 'creates as unsold inventories by default' do
          product.add_inventories(3)
          expect(product.inventories.available.count).to eq(3)
        end

        it 'creates one inventory if no arugment is given' do
          product.add_inventories
          expect(product.inventories.unsold.count).to eq(1)
        end
      end
    end

    context 'remove' do
      describe '#remove_inventory' do
        it 'removes unsold inventory' do
          product.add_inventories(2)
          product.send(:remove_inventory)
          expect(product.inventories.count).to eq(1)
        end

        it 'removes destroyable inventory if no unsold inventory is available' do
          FactoryGirl.create(:inventory, product: product, status: 1)
          order_inv = FactoryGirl.create(:inventory, product: product, status: 2)
          product.send(:remove_inventory)
          expect(product.inventories).to match_array([order_inv])
        end

        it 'removes the most recently changed inventory first' do
          inv_a = FactoryGirl.create(:inventory, product: product)
          inv_b = FactoryGirl.create(:inventory, product: product,
                                                 status: 2,
                                                 created_at: 3.days.ago,
                                                 updated_at: 2.days.ago)
          inv_a.in_order!
          product.send(:remove_inventory)
          expect(product.inventories).to match_array([inv_b])
        end

        it 'does not remove undestroyable inventory' do
          FactoryGirl.create(:inventory, product: product, status: 3)
          FactoryGirl.create(:inventory, product: product, status: 4)
          FactoryGirl.create(:inventory, product: product, status: 5)
          expect(product.send(:remove_inventory)).to be_falsey
          expect(product.inventories.count).to eq(3)
        end
      end

      describe '#remove_inventories' do
        it 'removes inventories' do
          5.times { FactoryGirl.create(:inventory, product: product) }
          product.remove_inventories(2)
          expect(product.inventories.count).to eq(3)
        end

        it 'removes all unsold inventories by default' do
          5.times { FactoryGirl.create(:inventory, product: product) }
          product.remove_inventories
          expect(product.inventories).to be_empty
        end

        it 'returns false if requested exceeds unsold inventories' do
          5.times { FactoryGirl.create(:inventory, product: product) }
          5.times { FactoryGirl.create(:inventory, product: product, status: 1) }
          expect(product.remove_inventories(10)).to be_falsey
          expect(product.inventories.count).to eq(10)
        end
      end

      describe '#force_remove_inventories' do
        it 'removes destroyable inventories' do
          5.times { FactoryGirl.create(:inventory, product: product, status: 1) }
          product.force_remove_inventories(3)
          expect(product.inventories.count).to eq(2)
        end

        it 'removes all destroyable inventories by default' do
          2.times { FactoryGirl.create(:inventory, product: product, status: 1) }
          3.times { FactoryGirl.create(:inventory, product: product, status: 2) }
          product.force_remove_inventories
          expect(product.inventories).to be_empty
        end

        it 'prioritize remove by status' do
          2.times { FactoryGirl.create(:inventory, product: product, status: 0) }
          2.times { FactoryGirl.create(:inventory, product: product, status: 1) }
          2.times { FactoryGirl.create(:inventory, product: product, status: 2) }
          product.force_remove_inventories(5)
          expect(product.inventories.in_order.count).to eq(1)
        end

        it 'return false when no destroyable is available' do
          FactoryGirl.create(:inventory, product: product, status: 3)
          FactoryGirl.create(:inventory, product: product, status: 4)
          FactoryGirl.create(:inventory, product: product, status: 5)
          expect(product.force_remove_inventories(1)).to be_falsey
          expect(product.inventories.count).to eq(3)
        end

        it 'allows deletion amount less than destroyable' do
          10.times { FactoryGirl.create(:inventory, product: product) }
          product.force_remove_inventories(3)
          expect(product.inventories.count).to eq(7)
        end
      end
    end
  end

  describe 'scope' do
    before do |example|
      unless example.metadata[:skip_before]
        @product_in_stock = FactoryGirl.create(:product)
        FactoryGirl.create(:inventory, product: @product_in_stock)

        @product_oos_destroyable = FactoryGirl.create(:product)
        FactoryGirl.create(:inventory, product: @product_oos_destroyable, status: 1)
        FactoryGirl.create(:inventory, product: @product_oos_destroyable, status: 2)

        @product_oos_undestroyable = FactoryGirl.create(:product)
        FactoryGirl.create(:inventory, product: @product_oos_undestroyable, status: 3)
        FactoryGirl.create(:inventory, product: @product_oos_undestroyable, status: 4)
        FactoryGirl.create(:inventory, product: @product_oos_undestroyable, status: 5)
      end
    end

    context '#in_stock' do
      it "returns products with unsold inventories" do
        result = Product.in_stock.distinct
        expect(result).to match_array([@product_in_stock])
      end
    end

    context '#out_of_stock' do
      it "returns product that are out of stock" do
        result = Product.out_of_stock.distinct
        expect(result).to match_array([@product_oos_destroyable,
                                       @product_oos_undestroyable])
      end

      # BUG CASE
      it 'does not return product with unsold inventories', skip_before: true do
        FactoryGirl.create(:inventory, product: product)
        FactoryGirl.create(:inventory, product: product, status: 2)
        expect(Product.count).to eq(1)
        expect(Product.out_of_stock).to be_empty
      end
    end
  end

end
