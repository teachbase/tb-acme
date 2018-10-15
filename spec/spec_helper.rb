# frozen_string_literal: true

RSpec.configure do |config|

  require 'fakeredis'
  require 'pry-byebug'
  require './boot'
  
  Boot.load
  
  $redis = Redis.new

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random
  Kernel.srand config.seed
end
