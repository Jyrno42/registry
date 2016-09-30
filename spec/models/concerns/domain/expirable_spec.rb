require 'rails_helper'

RSpec.describe Domain do
  before :context do
    Fabricate(:zonefile_setting, origin: 'ee')
  end

  describe '::expired' do
    before :example do
      Fabricate.create(:domain, id: 1, statuses: [DomainStatus::EXPIRED])
      Fabricate.create(:domain, id: 2, statuses: [DomainStatus::CLIENT_HOLD])
    end

    it 'returns expired domains' do
      expect(described_class.expired.ids).to eq([1])
    end
  end

  describe '#expired?' do
    context 'when :statuses contains expired status' do
      let(:domain) { Fabricate.build(:domain, statuses: [DomainStatus::EXPIRED]) }

      specify { expect(domain).to be_expired }
    end

    context 'when :statuses does not contain expired status' do
      let(:domain) { Fabricate.build(:domain, statuses: [DomainStatus::CLIENT_HOLD]) }

      specify { expect(domain).to_not be_expired }
    end
  end

  describe '#expirable?'
end
