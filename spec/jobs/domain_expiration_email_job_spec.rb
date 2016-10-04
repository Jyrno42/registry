require 'rails_helper'

RSpec.describe DomainExpirationEmailJob do
  describe '#perform' do
    let(:domain) { instance_double(Domain) }

    context 'when domain is registered' do
      before :example do
        allow(domain).to receive(:registered?).and_return(true)
      end
    end

    context 'when domain is expired' do
      before :example do
        allow(domain).to receive(:expired?).and_return(true)
      end
    end
  end
end
