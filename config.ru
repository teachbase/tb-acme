# frozen_string_literal: true

require './boot'
require './app'
require 'raven'

Boot.load

Raven.configure do |config|
  config.dsn = Config.settings['raven_dsn']
  config.environments = ['staging', 'production']
end

use Raven::Rack

use Rack::Session::Cookie,
    secret: ENV['SECRET'] || "tbacmesecredpasswordphrase"

run Cuba
