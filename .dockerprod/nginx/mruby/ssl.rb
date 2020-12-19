# frozen_string_literal: true

userdata = Userdata.new
ssl = Nginx::SSL.new

cert = userdata.redis.get("#{ssl.servername}.crt")
key = userdata.redis.get("#{ssl.servername}.key")

default_cert = '/nginx/certs/teachbase.crt'
default_key = '/nginx/certs/teachbase.key'

if cert && key
  ssl.certificate_data = cert
  ssl.certificate_key_data = key
else
  ssl.certificate = default_cert
  ssl.certificate_key = default_key
end
