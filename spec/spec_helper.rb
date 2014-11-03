# Useful to see that tests are using expected version of Ruby in CI
puts "Using #{RUBY_DESCRIPTION}"

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start do
    root          File.expand_path('../..', __FILE__)
    merge_timeout 3600
    # # command name is injected by the spec.rake runner
    # if ENV['BOSH_BUILD_NAME']
    #   command_name ENV['BOSH_BUILD_NAME']
    # end
  end
end

require 'rspec'
require 'rspec/its'


RSpec.configure do |config|
  #config.deprecation_stream = StringIO.new

  config.mock_with :rspec do |mocks|
    # Turn on after fixing several specs that stub out private methods
    # mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end
end

# require 'webmock/rspec'
require 'cli'
require 'bosh/cli/commands/aws'
require 'bosh_cli_plugin_aws'

Dir[File.expand_path('../support/*', __FILE__)].each { |f| require(f) }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
