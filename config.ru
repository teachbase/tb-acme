# frozen_string_literal: true

require './app'

use Rack::Session::Cookie,
    secret: ENV['SECRET'] || "tbacmesecredpasswordphrase"

run Cuba
