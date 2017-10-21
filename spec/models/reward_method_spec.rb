require 'rails_helper'

RSpec.describe RewardMethod, type: :model do

  let(:ref_reward) { FactoryBot.create(:ref_reward) }

  describe 'creation' do
    it 'can be created' do
      expect(ref_reward).to be_valid
    end
  end

  describe 'validations' do
    it 'cannot be created without name' do
      no_name = FactoryBot.build(:ref_reward, name: nil)
      expect(no_name).not_to be_valid
    end

    it 'cannot be created without variety' do
      no_variety = FactoryBot.build(:ref_reward, variety: nil)
      expect(no_variety).not_to be_valid
    end
  end

  describe '#load_settings' do
    it 'loads settings to virtual attributes' do
      expect(ref_reward.reload.percentage).to eq('5')
    end
  end

  describe '#destroyable?' do
    it 'returns true if reward method is not associated with any products' do
      reward_method = RewardMethod.create(name: 't', variety: 'referral')
      expect(reward_method.destroyable?).to be_truthy
    end

    it 'returns false is reward method is associated with any product' do
      expect(ref_reward.destroyable?).to be_falsey
    end
  end

end
