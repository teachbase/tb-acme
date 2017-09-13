require "cuba"
require "cuba/safe"
require 'logger'
require 'acme-client'
require 'redis'
require 'pry-byebug'
require 'json'
require 'openssl'

$logger = Logger.new($stdout)
$redis = Redis.new(host: 'localhost', port: 6379, db: 0)

Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require(f) }

Cuba.define do
  on root do
    res.write 'Hello cuba!'
  end

  on 'api' do
    on 'v1' do
      on post do
        on 'register' do
          data = if req.env["CONTENT_TYPE"] == 'application/json'
                  JSON.parse req.body.read
                else
                  {}
                end
          
          CertService.handle(data)
          res.write "ok"
        end
      end
    end
  end
end
