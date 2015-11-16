$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../spec/dummy/config/environment", __FILE__)

if RUBY_VERSION.to_i >= 2
  require 'byebug'
else
  require 'debugger'
end

require 'gxapi'

require 'rspec/rails'
require 'capybara/rails'
require 'rails/engine'
require 'mocha/setup'
require 'webmock/rspec'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Mocha::Configuration.prevent(:stubbing_non_existent_method)

RSpec.configure do |config|
  config.mock_with :mocha

  config.run_all_when_everything_filtered = true
  config.include Rails.application.routes.url_helpers
  config.infer_spec_type_from_file_location!

  config.filter_run focus: true

  config.before(:all) do
    Gxapi.logger = Logger.new(STDOUT)
  end

end
