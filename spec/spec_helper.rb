# frozen_string_literal: true

require "bundler/setup"
require "rails_fields_kit"
require "action_view"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end
