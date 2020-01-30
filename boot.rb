# frozen_string_literal: true

require 'redis'
require 'cuba'
require 'cuba/safe'
require 'acme-client'
require 'pry-byebug'
require 'json'
require 'openssl'
require 'logger'
require 'raven'

Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require(f) }

class Boot
  def self.load
    Raven.configure do |config|
      config.dsn = ENV['RAVEN_DSN']
      config.environments = ['staging', 'production']
    end

    $logger = ::Logger.new(STDOUT)

    redis_params = Config.settings['redis_master'].transform_keys(&:to_sym)
    $redis  = ::Redis.new(**redis_params)
  end
end
