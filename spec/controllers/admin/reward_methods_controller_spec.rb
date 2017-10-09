require 'rails_helper'

RSpec.describe Admin::RewardMethodsController, type: :controller do

  let(:admin)      { FactoryGirl.create(:admin) }
  let(:ref_reward) { FactoryGirl.create(:ref_reward) }

  before { signin_as admin }

  describe 'GET index' do
    it 'responses successfully' do
      get :index
      expect(response).to be_success
    end
  end

  describe 'GET new' do
    it 'renders new form' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST create' do
    context 'with valid params' do
      let(:valid_ref_attrs) {{
        name: 'Referral Reward',
        variety: 'referral',
        percentage: '10'
      }}

      it 'creates a reward method' do
        expect {
          post :create, params: { reward_method: valid_ref_attrs }
        }.to change(RewardMethod, :count).by(1)
      end

      it 'sets percentage attribute for referral type method' do
        post :create, params: { reward_method: valid_ref_attrs }
        expect(RewardMethod.last.reload.percentage).to eq('10')
      end

      it 'redirects to reward method show action' do
        post :create, params: { reward_method: valid_ref_attrs }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admin_reward_method_path RewardMethod.last)
      end
    end

    context 'with invalid params' do
      it 'renders error messages when params is invalid' do
        post :create, params: { reward_method: { name: '' } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET show' do
    it 'responses successfully' do
      get :show, params: { id: ref_reward.id }
      expect(response).to be_success
    end
  end

  describe 'GET edit' do
    it 'responses successfully' do
      get :edit, params: { id:ref_reward.id }
      expect(response).to be_success
    end
  end

  describe 'PATCH update' do
    context 'with valid params' do
      it 'updates record' do
        patch :update, params: {
          id: ref_reward, reward_method: { name: 'New Name' }
        }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admin_reward_method_path(ref_reward))
      end

      it 'updates settings hash for referral attributes' do
        patch :update, params: {
          id: ref_reward, reward_method: { percentage: '20' }
        }
        expect(ref_reward.reload.percentage).to eq('20')
      end
    end

    context 'with invalid params' do
      it 'flashes error messages when given invalid params' do
        patch :update, params: { id: ref_reward, reward_method: { name: '' } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE destroy' do
    before do
      @reward_method = RewardMethod.create(name: 'Test', variety: 'referral')
    end
    it 'destroys reward method without associated products' do
      expect {
        delete :destroy, params: { id: @reward_method.id }
      }.to change(RewardMethod, :count).by(-1)
    end

    it 'destorys and return to index' do
      delete :destroy, params: { id: @reward_method.id }
      expect(flash[:success]).to be_present
      expect(response).to redirect_to admin_reward_methods_path
    end

    it 'flashes error message if associated products exist' do
      delete :destroy, params: { id: ref_reward.id }
      expect(flash[:warning]).to be_present
      expect(response).to redirect_to admin_reward_methods_path
    end
  end
end
