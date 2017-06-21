require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the UsersHelper. For example:
#
# describe UsersHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe UsersHelper, type: :helper do

  describe '#is_email?' do
    it 'return true when ident params is an email address' do
      allow(helper).to receive(:params)
                       .and_return( {user: { ident: 'example@email.com' } })
      expect(helper.is_email?).to be_truthy
    end

    it 'return false when ident params does not include an email address' do
      allow(helper).to receive(:params)
                       .and_return( { user: { ident: 'abc'} })
      expect(helper.is_email?).to be_falsy
    end
  end

  describe '#is_cell_number' do
    it 'return true when ident params is an cell number' do
      allow(helper).to receive(:params)
                       .and_return( {user: { ident: '18655555555' } })
      expect(helper.is_cell_number?).to be_truthy
    end

    it 'return false when ident params does not include an cell number' do
      allow(helper).to receive(:params)
                       .and_return( { user: { ident: 'abcd'} })
      expect(helper.is_cell_number?).to be_falsy
    end
  end

  describe '#convert_ident' do
    it 'converts ident to email' do
      allow(helper).to receive(:params)
                       .and_return( {user: { ident: 'example@email.com' } })
      helper.convert_ident
      expect(helper.params[:user][:email]).to eq('example@email.com')
    end

    it 'converts ident to cell number' do
      allow(helper).to receive(:params)
                       .and_return( {user: { ident: '17600000000' } })
      helper.convert_ident
      expect(helper.params[:user][:cell_number]).to eq('17600000000')
    end

    it 'does not set any params when ident does not contain email or cell number' do
      allow(helper).to receive(:params)
                       .and_return( {user: { ident: '123123abcd' } })
      helper.convert_ident
      expect(helper.params[:user][:email]).to be_nil
      expect(helper.params[:user][:cell_number]).to be_nil
    end
  end

end
