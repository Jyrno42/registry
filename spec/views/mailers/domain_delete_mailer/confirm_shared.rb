require 'rails_helper'

RSpec.shared_examples 'domain delete mailer confirm' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:lang_count) { 2 }

  before :example do
    assign(:domain, domain)
    assign(:registrar, nil)
    assign(:confirm_url, 'test confirm url')
  end

  it 'has registrar info in estonian' do
    render
    expect(rendered).to have_text('test registrar estonian')
  end

  it 'has registrar info in english' do
    render
    expect(rendered).to have_text('test registrar english')
  end

  it 'has domain name' do
    mention_count = 1 * lang_count
    expect(domain).to receive(:name).exactly(mention_count).times.and_return('test domain name')
    render
    expect(rendered).to have_text('test domain name', count: mention_count)
  end

  it 'has confirm url' do
    mention_count = 1 * lang_count
    render
    expect(rendered).to have_text('test confirm url', count: mention_count)
  end
end
