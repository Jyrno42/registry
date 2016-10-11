# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'capybara/poltergeist'
require 'paper_trail/frameworks/rspec'
PaperTrail.whodunnit = 'autotest'
require "money-rails/test_helpers"

if ENV['ROBOT']
  require 'simplecov'
  SimpleCov.start 'rails'
end

require 'support/matchers/alias_attribute'
require 'support/matchers/active_job'
require 'support/capybara'
require 'support/database_cleaner'
require 'support/epp'
require 'support/epp_doc'
require 'support/feature'
require 'support/registrar_helpers'
require 'support/request'
require 'support/autodoc'

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
#ActiveRecord::Migration.maintain_test_schema!

# create general settings
def create_settings
  Setting.ds_algorithm = 2
  Setting.ds_data_allowed = false
  Setting.ds_data_with_key_allowed = true
  Setting.key_data_allowed = true

  Setting.dnskeys_min_count = 0
  Setting.dnskeys_max_count = 9
  Setting.ns_min_count = 2
  Setting.ns_max_count = 11

  Setting.transfer_wait_time = 0

  Setting.admin_contacts_min_count = 1
  Setting.admin_contacts_max_count = 10
  Setting.tech_contacts_min_count = 0
  Setting.tech_contacts_max_count = 10

  Setting.client_side_status_editing_enabled = true
end

RSpec.configure do |config|
  config.include ActionView::TestCase::Behavior, type: :presenter
  config.include ActiveSupport::Testing::TimeHelpers

  config.define_derived_metadata(file_path: %r{/spec/presenters/}) do |metadata|
    metadata[:type] = :presenter
    metadata[:db] = false
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # config.before(:all) do
  #   create_settings
  # end
  #
  # config.before(:all, epp: true) do
  #   create_settings
  # end
  #
  # config.before(:each, js: true) do
  #   create_settings
  # end
  #
  # config.before(:each, type: :request) do
  #   create_settings
  # end
  #
  # config.before(:each, type: :model) do
  #   create_settings
  # end


  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
