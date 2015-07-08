ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.after(:all) do
    if Rails.env.test?
      FileUtils.rm_f(Dir[WordBasket.configuration.database_options[:storage_path]])
    end
  end
end

WordBasket.configure do |config|
  config.database_adapter = 'local_file'
  config.database_options = { storage_path: Rails.root.join('db/words_test.json') }
end

# Set up Coveralls
require 'coveralls'
Coveralls.wear!
