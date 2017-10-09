require 'rails_helper'

RSpec.describe Admin::RewardMethodsController, type: :controller do

  let(:admin) { FactoryGirl.create(:admin) }

  before { signin_as admin }


end
