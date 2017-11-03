require 'bundler/setup'
require 'rspec/its'
require 'simplecov'
SimpleCov.start

require 'arduino/library'

TEMP_INDEX = '/tmp/library_index.json.gz'

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

  config.before :all, local_index: true do
    FileUtils.cp('spec/fixtures/library_index.json.gz', TEMP_INDEX)
    Arduino::Library::DefaultDatabase.library_index_path = TEMP_INDEX
    Arduino::Library::DefaultDatabase.instance.setup
  end
  config.after :all, local_index: true do
    FileUtils.rm_f(TEMP_INDEX)
  end
end
