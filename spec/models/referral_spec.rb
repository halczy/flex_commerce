require 'rails_helper'

RSpec.describe Referral, type: :model do

  let(:customer) { FactoryGirl.create(:customer) }
  let(:referral) { FactoryGirl.create(:referral) }

  describe 'creation' do
    it 'can be created' do
      expect(referral).to be_valid
    end

    context 'validations' do
      it 'does not allow duplicate referee record' do
        referral
        expect(
          Referral.new(referer: customer, referee: referral.referee)
        ).not_to be_valid
      end

      it 'does not allow referer and referee to be the same user' do
        expect(Referral.new(referer: customer, referee: customer)).not_to be_valid
      end

      it 'cannot be craeted without a referer' do
        expect(Referral.new(referee: customer)).not_to be_valid
      end

      it 'cannot be created without a referee' do
        expect(Referral.new(referer: customer)).not_to be_valid
      end
    end
  end

  describe 'relationship' do
    it 'has customer as a referer' do
      expect(referral.referer).to be_an_instance_of Customer
    end

    it 'allow customer to get referer' do
      cstm = referral.referee
      expect(cstm.referer).to eq(referral.referer)
    end

    it 'has customer as a referee' do
      expect(referral.referee).to be_an_instance_of Customer
    end

    it 'allow customer to get referees' do
      cstm = referral.referer
      3.times { FactoryGirl.create(:referral, referer: cstm) }
      expect(cstm.referees.count).to eq(4)
      expect(cstm.referees).to include(referral.referee)
    end
  end
end
