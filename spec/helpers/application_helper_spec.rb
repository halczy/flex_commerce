require "rails_helper"

RSpec.describe ApplicationHelper, :type => :helper do

  describe "#page_title" do
    let(:base_title) { "Flex Commerce" }

    it "returns the instance variable + base title" do
      expect(helper.page_title('Test Title'))
        .to eql("Test Title | #{base_title}")
    end

    it 'returns only base title when no instance variable is provided' do
      expect(helper.page_title).to eql("#{base_title}")
    end

    it 'returns base title from database' do
      ApplicationConfiguration.create(name: 'application_title',
                                      plain: 'Flex Shop')
      expect(helper.page_title).to eq('Flex Shop')
    end
  end

  describe '#app_title' do
    it 'returns value from app configs' do
      ApplicationConfiguration.create(name: 'application_title', plain: 'Flex Shop')
      expect(helper.app_title).to eq('Flex Shop')
    end

    it 'returns default value if app configs does not exist' do
      expect(helper.app_title).to eq('Flex Commerce')
    end
  end

  describe '#icp_license' do
    it 'returns icp license when present' do
      ApplicationConfiguration.create(name: 'icp_license', plain: '12-345')
      expect(helper.icp_license).to eq('12-345')
    end

    it 'returns nil if icp license is not setup' do
      expect(helper.icp_license).to be_nil
    end

    it 'returns nil if value is empty' do
      ApplicationConfiguration.create(name: 'icp_license', plain: '')
      expect(helper.icp_license).to be_nil
    end
  end

  describe '#alert_icon' do
    it 'returns success icon class' do
      expect(helper.alert_icon('success')).to eq('fa-check-circle')
    end

    it 'returns nothing if message_type is not declared' do
      expect(helper.alert_icon('random')).to be_nil
    end
  end
end
