$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../spec/dummy/config/environment", __FILE__)

require 'moona'

require 'rspec/rails'
require 'rails/engine'
require 'mocha/setup'

require 'ruby-debug'
Debugger.start

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Mocha::Configuration.prevent(:stubbing_non_existent_method)

RSpec.configure do |config|
  config.mock_with :mocha

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true

  config.filter_run :focus => true
end
