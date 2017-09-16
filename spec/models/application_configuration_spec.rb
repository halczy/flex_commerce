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
end
