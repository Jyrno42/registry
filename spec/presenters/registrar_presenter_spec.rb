require 'rails_helper'

RSpec.describe RegistrarPresenter do
  let(:registrar) { instance_double(Registrar) }
  let(:presenter) { described_class.new(registrar: registrar, view: view) }

  describe '#to_s' do
    before :example do
      expect(registrar).to receive(:name).and_return('test name')
    end

    it 'returns name' do
      expect(presenter.to_s).to eq('test name')
    end
  end
end
