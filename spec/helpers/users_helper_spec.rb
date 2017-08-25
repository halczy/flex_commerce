require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do

  describe '#is_email?' do
    it 'returns true when ident params is an email address' do
      allow(helper).to receive(:params)
                       .and_return({ customer: { ident: 'example@email.com' } })
      expect(helper.is_email?).to be_truthy
    end

    it 'returns false when ident params does not include an email address' do
      allow(helper).to receive(:params)
                       .and_return({ customer: { ident: 'abc'} })
      expect(helper.is_email?).to be_falsy
    end
  end

  describe '#is_cell_number?' do
    it 'returns true when ident params is an cell number' do
      allow(helper).to receive(:params)
                       .and_return({ customer: { ident: '18655555555' } })
      expect(helper.is_cell_number?).to be_truthy
    end

    it 'returns false when ident params does not include an cell number' do
      allow(helper).to receive(:params)
                       .and_return({ customer: { ident: 'abcd'} })
      expect(helper.is_cell_number?).to be_falsy
    end
  end
  
  describe '#is_member_id?' do
    it "returns true when ident params is a member id" do
      allow(helper).to receive(:params)
                       .and_return( {customer: { ident: '123456'} })
      expect(helper.is_member_id?).to be_truthy
    end
    
    it "returns true when ident params is a dash member id" do
      allow(helper).to receive(:params).
                       and_return({ customer: { ident: '123-456' } })
      expect(helper.is_member_id?).to be_truthy
    end
    
    it "returns false hwen ident params is not a member id" do
      allow(helper).to receive(:params).
                       and_return({ customer: { ident: 'a123987a@gmail.com'} })
      expect(helper.is_member_id?).to be_falsy
    end
  end

  describe '#convert_ident' do
    it 'converts ident to email' do
      allow(helper).to receive(:params)
                       .and_return({ customer: { ident: 'example@email.com' } })
      helper.convert_ident
      expect(helper.params[:customer][:email]).to eq('example@email.com')
    end

    it 'converts ident to cell number' do
      allow(helper).to receive(:params)
                       .and_return({ customer: { ident: '17600000000' } })
      helper.convert_ident
      expect(helper.params[:customer][:cell_number]).to eq('17600000000')
    end
    
    it "converts ident to member id" do
      allow(helper).to receive(:params)
                       .and_return({ customer: { ident: '123456' } })
      helper.convert_ident
      expect(helper.params[:customer][:member_id]).to eq('123456')
    end
    
    it "converts dashed ident to member id" do
      allow(helper).to receive(:params)
                       .and_return({ customer: { ident: '123-456' } })
      helper.convert_ident
      expect(helper.params[:customer][:member_id]).to eq('123456')
    end
    
    

    it 'does not set any params when ident does not contain email or cell number' do
      allow(helper).to receive(:params)
                       .and_return({ customer: { ident: '123123abcd' } })
      helper.convert_ident
      expect(helper.params[:customer][:email]).to be_nil
      expect(helper.params[:customer][:cell_number]).to be_nil
    end
  end

end
