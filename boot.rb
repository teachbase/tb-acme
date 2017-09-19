require 'logger'
require 'redis'

class Boot
  def self.load
    $logger = ::Logger.new($stdout)
    $redis = ::Redis.new(host: 'localhost', port: 6379, db: 0)
  end
end
