require 'rails_helper'

RSpec.describe Domain do
  describe '#expired?', db: false do
    context 'when :statuses contains expired status' do
      let(:domain) { described_class.new(statuses: [DomainStatus::EXPIRED]) }

      specify { expect(domain).to be_expired }
    end

    context 'when :statuses does not contain expired status' do
      let(:domain) { described_class.new(statuses: [DomainStatus::CLIENT_HOLD]) }

      specify { expect(domain).to_not be_expired }
    end
  end
end
