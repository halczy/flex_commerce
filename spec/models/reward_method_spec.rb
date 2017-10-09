require 'rails_helper'

RSpec.describe RewardMethod, type: :model do

  let(:ref_reward) { FactoryGirl.create(:ref_reward) }

  describe 'creation' do
    it 'can be created' do
      expect(ref_reward).to be_valid
    end
  end

end
