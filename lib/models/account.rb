# frozen_string_literal: true

require './lib/models/redis'

module Models
  class Account < Redis
    set_attributes :id, :name, :private_key, :domain, :cert_created_at,
                  :cert_expired_at, :auth_status, :auth_uri, :domain_private_key,
                  :domain_cert, :kid

    def same_domain?(external)
      return false unless external
      domain == external
    end

    def reset_private_key
      self.private_key = OpenSSL::PKey::RSA.new(4096)
    end
  end
end
