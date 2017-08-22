require "cuba"
require "cuba/safe"
require 'logger'
require 'acme-client'
require 'redis'
require 'pry-byebug'
require 'json'

require 'openssl'

$redis = Redis.new(host: 'localhost', port: 6379, db: 0)
$acme_endpoint = 'https://acme-staging.api.letsencrypt.org/'.freeze
$public_path = '/webapps/teachbase/teachbase2/public'.freeze

Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require(f) }

Cuba.define do
  on 'api' do
    on 'v1' do
      on post do
        on 'register' do
          data = if req.env["CONTENT_TYPE"] == 'application/json'
                  JSON.parse req.body.read
                else
                  {}
                end
          
          account_id = data.fetch('id', 0)
          
          if account = Account.find(account_id)
            # get account data and private key.
          else
            # register new account.
            account = Account.new(data)
            account.private_key = OpenSSL::PKey::RSA.new(4096)
            account.save

            registrator = CryptoRegistrator.new(account)
            registrator.register
            binding.pry
          end

          res.write "ok"
        end
      end
    end
  end
end
