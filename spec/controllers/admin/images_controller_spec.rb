require 'rails_helper'

RSpec.describe Admin::ImagesController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }
  let(:image) { FactoryGirl.create(:image) }

end
