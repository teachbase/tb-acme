userdata = Userdata.new
ssl = Nginx::SSL.new
ssl.certificate_data = userdata.redis.get("#{ssl.servername}.crt")
ssl.certificate_key_data = userdata.redis.get("#{ssl.servername}.key")
