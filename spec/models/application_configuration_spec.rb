require 'rails_helper'

RSpec.describe ApplicationConfiguration, type: :model do

  describe 'creation' do
    it 'can be created' do
      sample_config = ApplicationConfiguration.new(name: 'Test',
                                                   value: 'secret')
      expect(sample_config).to be_valid
    end

    it 'downcase name before save' do
      sample = ApplicationConfiguration.create(name: 'TeSt', value: 'X')
      expect(sample.name).to eq('test')
    end
  end

  describe 'validation' do
    it 'must have a name' do
      no_name = ApplicationConfiguration.new(value: 'secret_data')
      expect(no_name).not_to be_valid
    end

    it 'cannot have duplicate name' do
      sample = ApplicationConfiguration.create(name: 'SiteName', value: 'X')
      dup_sample = ApplicationConfiguration.create(name: 'sitenAme', value: 'X')
      expect(dup_sample).not_to be_valid
    end
  end

  describe '#self.get' do
    it 'gets encrypted value' do
      ApplicationConfiguration.create(name: 'v_test', value: 'encrypted_value')
      expect(ApplicationConfiguration.get('v_test')).to eq('encrypted_value')
    end

    it 'gets plain value' do
      ApplicationConfiguration.create(name: 'p_test', plain: 'plain_value')
      expect(ApplicationConfiguration.get('p_test')).to eq('plain_value')
    end

    it 'gets boolean value' do
      ApplicationConfiguration.create(name: 'b_test', status: false)
      expect(ApplicationConfiguration.get('b_test')).to eq(false)
    end

    it 'returns nil when no config is found' do
      expect(ApplicationConfiguration.get('random')).to be_nil
    end

    it 'does not return empty value' do
      ApplicationConfiguration.create(name: 'empty_vtest', value: '', plain: 'abc')
      expect(ApplicationConfiguration.get('empty_vtest')).to eq('abc')
    end

    it 'returns nil when all fields are empty or nil' do
      ApplicationConfiguration.create(name: 'empty', value: '', plain: '')
      expect(ApplicationConfiguration.get('empty')).to be_nil
    end
  end
end
