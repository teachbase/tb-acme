# frozen_string_literal: true

require 'redis'
require 'cuba'
require 'cuba/safe'
require 'acme-client'
require 'pry-byebug'
require 'json'
require 'openssl'

Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require(f) }

class Boot
  def self.load
    config = YAML.load_file("#{File.dirname(__FILE__)}/config/secrets.yml").fetch('production', {})
    shared_dir = "#{config['remote_path']}/shared"
    $logger = ::Logger.new("#{shared_dir}/log/stdout")
    $redis = ::Redis.new(host: 'localhost', port: 6379, db: 0)
  end
end
