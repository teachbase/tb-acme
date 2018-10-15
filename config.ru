# frozen_string_literal: true

require './boot'
require './app'

Boot.load

use Rack::Session::Cookie,
    secret: ENV['SECRET'] || "tbacmesecredpasswordphrase"

run Cuba
