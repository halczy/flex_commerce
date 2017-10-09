require 'rails_helper'

describe 'Reward Method CRUD', type: :feature do

  let(:admin)      { FactoryGirl.create(:admin) }
  let(:ref_reward) { FactoryGirl.create(:ref_reward) }

  before { feature_signin_as admin }

  describe 'create' do
    it 'can create referral type reward method' do
      visit admin_reward_methods_path
      click_on 'New Reward Method'
      fill_in 'reward_method[name]', with: 'Feature Test'
      fill_in 'reward_method[percentage]', with: '12'
      select 'Referral', from: 'reward_method[variety]'
      click_on 'Submit'

      expect(page.current_path).to eq(admin_reward_method_path(RewardMethod.last))
      expect(page).to have_content('Feature Test')
      expect(page).to have_content('Percentage 12%')
      expect(page).to have_content('Referral')
    end

    it 'displays error message when name is not filled' do
      visit admin_reward_methods_path
      click_on 'New Reward Method'
      click_on 'Submit'

      expect(page).to have_css('#error_messages')
    end
  end

  describe 'edit' do
    it 'can edit existing reward' do
      ref_reward
      visit admin_reward_methods_path
      click_on 'Edit'
      fill_in 'reward_method[name]', with: 'Feature Test'
      fill_in 'reward_method[percentage]', with: '12'
      select 'Referral', from: 'reward_method[variety]'
      click_on 'Submit'

      expect(page.current_path).to eq(admin_reward_method_path(RewardMethod.last))
      expect(page).to have_content('Feature Test')
      expect(page).to have_content('Percentage 12%')
      expect(page).to have_content('Referral')
    end

    it 'displays error message when edited param is invalid' do
      ref_reward
      visit admin_reward_methods_path
      click_on 'Edit'
      fill_in 'reward_method[name]', with: ''
      click_on 'Submit'

      expect(page).to have_css('#error_messages')
    end
  end

  describe 'destroy' do
    it 'can delete unassociated reward method' do
      visit admin_reward_methods_path
      click_on 'New Reward Method'
      fill_in 'reward_method[name]', with: 'Feature Test'
      fill_in 'reward_method[percentage]', with: '12'
      select 'Referral', from: 'reward_method[variety]'
      click_on 'Submit'
      click_on 'Delete'
      click_on 'Confirm'

      expect(page).to have_content('No Reward Method Available')
    end

    it 'cannot delete reward method with product asscoiated' do
      ref_reward
      visit admin_reward_methods_path
      click_on 'Delete'
      click_on 'Confirm'

      expect(page).to have_content('This reward method cannot be deleted.')
    end
  end
end
