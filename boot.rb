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
    log_file = "#{Config.settings['remote_path']}/shared/log/stdout"
    $logger  = ::Logger.new(log_file)
    $redis   = ::Redis.new(host: 'localhost', port: 6379, db: 0)

    Raven.configure do |config|
      config.dsn = Config.settings['raven_dsn']
      config.environments = ['staging', 'production']
    end
  end
end
