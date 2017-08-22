require './app'

use Rack::Session::Cookie,
    secret: ENV['SECRET'] || "tbacmesecredpasswordphrase"

run Cuba
