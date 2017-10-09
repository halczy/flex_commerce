require 'rails_helper'

RSpec.describe RewardMethod, type: :model do

  let(:ref_reward) { FactoryGirl.create(:ref_reward) }

  describe 'creation' do
    it 'can be created' do
      expect(ref_reward).to be_valid
    end
  end

  describe 'validations' do
    it 'cannot be created without name' do
      no_name = FactoryGirl.build(:ref_reward, name: nil)
      expect(no_name).not_to be_valid
    end

    it 'cannot be created without variety' do
      no_variety = FactoryGirl.build(:ref_reward, variety: nil)
      expect(no_variety).not_to be_valid
    end
  end

  describe '#load_settings' do
    it 'loads settings to virtual attributes' do
      expect(ref_reward.reload.percentage).to eq('5')
    end
  end

end
