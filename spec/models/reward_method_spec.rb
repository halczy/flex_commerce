require 'rails_helper'

RSpec.describe RewardMethod, type: :model do

  let(:ref_reward) { FactoryGirl.create(:ref_reward) }

  describe 'creation' do
    it 'can be created' do
      expect(ref_reward).to be_valid
    end
  end

  describe '#load_settings' do
    it 'loads settings to virtual attributes' do
      expect(ref_reward.reload.percentage).to eq('5')
    end
  end

end
