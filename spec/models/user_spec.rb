require 'rails_helper'

RSpec.describe User, type: :model do

  before do
    @user_with_email = User.create(email: 'spec_email@example.com',
                                   password: 'example',
                                   password_confirmation: 'example')
    @user_with_cell = User.create(cell_number: '18612344321',
                                  password: 'example',
                                  password_confirmation: 'example')
  end

  let(:user) { FactoryGirl.create(:user) }

  describe 'creation' do
    it 'can be created' do
      expect(@user_with_email).to be_valid
      expect(@user_with_cell).to be_valid
    end
  end

  describe 'validation' do
    it 'cannot be created without either email or cell_number' do
      @user_with_email.email = nil
      @user_with_cell.cell_number = nil
      expect(@user_with_email).not_to be_valid
      expect(@user_with_cell).not_to be_valid
    end

    describe 'email' do
      it 'allows user with valid address to sign up' do
        valid_addresses =  %w[user@example.com USER@FOO.com A_US-ER@gov.com.br
                              last_name.first@abc.co first+last@abc.co.jp]
        valid_addresses.each do |valid_address|
          @user_with_email.email = valid_address
          expect(@user_with_email).to be_valid
        end
      end

      it 'ensures email is downcased before saving' do
        case_email = 'ALLCAP@CAPLETTER.CO'
        @user_downcase = User.create(email: case_email,
                                     password: 'example',
                                     password_confirmation: 'example')
        expect(@user_downcase).to be_valid
        expect(@user_downcase.email).to eq(case_email.downcase)
      end

      it 'prevents user with invalid address to sign up' do
        invalid_addresses = %w[user@example,com user_at_example.com
                               fo@bar_bar_bar.com boo@bar+can.org
                               foo@bar..com. fo@bar...com foo..@ba...r.com]

        invalid_addresses.each do |invalid_address|
          @user_with_email.email = invalid_address
          expect(@user_with_email).not_to be_valid
        end
      end
    end

    describe 'cell_number' do
      it 'allows sign up with valid phone number' do
        valid_cell_numbers = %w[18612345678 15012345678 17012345678
                                18112345678 17712345678 14500000000]
        valid_cell_numbers.each do |valid_cell_number|
          @user_with_cell.cell_number = valid_cell_number
          expect(@user_with_cell).to be_valid
        end
      end

      it 'does not allow user to sign up with invalid number' do
        invalid_cell_numbers = %w[10012345678, 6085554789, +8613712345678,
                                  08618912345678, 8613786781234, 3258-7899
                                  01012345678, 010-12345678]
        invalid_cell_numbers.each do |invalid_cell_number|
          @user_with_cell.cell_number = invalid_cell_number
          expect(@user_with_cell).not_to be_valid
        end
      end
    end

    describe 'password' do
      it 'cannot allow user to sign up without password' do
        user_nopass = User.create(email: 'no_password@example.com')
        expect(user_nopass).not_to be_valid
      end

      it 'cannot be too short' do
        @user_with_email.password = 'a' * 4
        @user_with_email.password_confirmation = @user_with_email.password
        expect(@user_with_email).not_to be_valid
      end

      it 'cannot be too long' do
        @user_with_email.password = 'a' * 54
        @user_with_email.password_confirmation = @user_with_email.password
        expect(@user_with_email).not_to be_valid
      end
    end
  end

  describe '#forget' do
    it 'sets remember_token to nil' do
      user.forget
      expect(user.remember_token).to be_nil
    end
  end
end
