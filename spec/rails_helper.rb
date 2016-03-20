require 'simplecov'
SimpleCov.start 'rails'
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'factory_girl'
require 'webmock/rspec'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.full_backtrace = false
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.include Devise::TestHelpers, :type => :controller
  config.include Warden::Test::Helpers
  config.include FactoryGirl::Syntax::Methods
  
  config.before do
    WebMock.disable_net_connect!(allow_localhost: true)
    stub_request(:get, "https://my-email-bucket.s3.amazonaws.com/test")
      .to_return(status: 200, body: File.read('spec/support/lambda_email'))
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:suite) do
    DatabaseCleaner.start 
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end
  
end