# frozen_string_literal: true

require 'bundler/setup'
require 'tau'
require 'webmock/rspec'

# Load support files
Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Disable real HTTP requests in tests
  config.before(:each) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  config.after(:each) do
    WebMock.reset!
  end
end
