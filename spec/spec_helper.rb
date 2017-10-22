require 'bundler/setup'
require 'rspec/its'
require 'simplecov'
SimpleCov.start

require 'arduino/library'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  unless ENV['CI']
    config.filter_run_excluding ci_only: true
  end
  
end
