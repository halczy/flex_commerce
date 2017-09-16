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
                                      value: 'Flex Shop')
      expect(helper.page_title).to eq('Flex Shop')
    end
  end

end
