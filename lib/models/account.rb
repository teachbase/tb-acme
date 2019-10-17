# frozen_string_literal: true

require './lib/models/redis'

module Models
  class Account < Redis
    set_attributes :id, :name, :private_key, :domain, :cert_created_at,
                  :cert_expired_at, :auth_status, :auth_uri, :domain_private_key,
                  :domain_cert, :kid

    class << self
      def create(params)
        account = new(params)
        account.reset_private_key
        account.save
        account
      end

      def find_or_create_by(params)
        account = find(params.fetch('id', 0))

        return create(params) if account.nil?

        new_host = params['domain']
        if new_host && !account.same_domain?(new_host)
          account.domain = new_host
        end
        account.reset_private_key
        account.save
        account
      end
    end

    def same_domain?(external)
      return false unless external
      domain == external
    end

    def reset_private_key
      self.private_key = OpenSSL::PKey::RSA.new(4096)
    end
  end
end
