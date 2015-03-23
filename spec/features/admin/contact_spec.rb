require 'rails_helper'

feature 'Admin contact', type: :feature do
  background { create_settings }

  before :all do
    @user = Fabricate(:admin_user, username: 'user1', identity_code: '37810013087')
    @contact = Fabricate(:contact, name: 'Mr John')
  end

  it 'should show index of contacts' do
    sign_in @user
    visit admin_contacts_url

    page.should have_content('Mr John')
  end

  it 'should show correct contact creator' do
    sign_in @user
    visit admin_contacts_url

    click_link('Mr John')
    page.should have_content('by autotest')
  end
end
