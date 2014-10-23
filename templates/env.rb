ENV['RAILS_ENV'] = 'test'
require './config/environment'

require 'minitest/spec'
require 'spinach/capybara'
require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 90)
end

Spinach.hooks.on_tag("javascript") do
  ::Capybara.current_driver = ::Capybara.javascript_driver
end

Capybara.default_wait_time = 60
Capybara.ignore_hidden_elements = false

DatabaseCleaner.strategy = :truncation

Spinach.hooks.before_scenario do
  DatabaseCleaner.start
end

Spinach.hooks.after_scenario do
  DatabaseCleaner.clean
end

Spinach.hooks.before_run do
#  TestEnv.init(mailer: false)
#  RSpec::Mocks::setup self
#  include FactoryGirl::Syntax::Methods
end
