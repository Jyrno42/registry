require 'rails_helper'

RSpec.describe Domain, db: false do
  it { is_expected.to alias_attribute(:expire_time, :valid_to) }

  describe '#expired?' do
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
