# frozen_string_literal: true

require './boot'
require './app'
require 'raven'

Boot.load

use Raven::Rack

use Rack::Session::Cookie,
    secret: ENV['SECRET'] || "tbacmesecredpasswordphrase"

run Cuba
