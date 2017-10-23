require './lib/redis_model'

class Account < RedisModel
  set_attributes :id, :name, :private_key, :domain, :cert_created_at,
                 :cert_expired_at, :auth_status, :auth_uri, :domain_private_key,
                 :domain_cert

  def same_domain?(external)
    return false unless external
    domain == external
  end
end
