require 'rails_helper'

RSpec.describe RegistrarPresenter do
  describe '#name' do
    let(:registrar) { instance_double(Registrar) }
    let(:presenter) { described_class.new(registrar: registrar, view: nil) }

    it 'returns name' do
      expect(registrar).to receive(:name).and_return('test name')
      expect(presenter.name).to eq('test name')
    end
  end
end
