# frozen_string_literal: true

module Stages
  class Store
    extend Forwardable

    def initialize(resource)
      @resource = resource
    end

    def_delegators :@resource, :certificate, :account, :private_key

    def call
      return @resource if @resource.invalid?

      write_to_filesystem
      write_to_account
      write_to_storage
      @resource
    end

    private

    def private_key_pem
      private_key.to_pem
    end

    def write_to_filesystem
      FileUtils.mkdir_p(private_path) unless Dir.exists?(private_path)
      File.write("#{private_path}/#{account.domain}.key", private_key_pem)
      File.write("#{private_path}/#{account.domain}.crt", certificate)
      $logger.info('[OK] Certificate saved to filesystem')
    end

    def write_to_account
      account.domain_cert        = certificate
      account.domain_private_key = private_key_pem
      account.save
      $logger.info('[OK] Certificate saved to account')
    end

    def write_to_storage
      $redis.set("#{account.domain}.crt", certificate)
      $redis.set("#{account.domain}.key", private_key_pem)
      $logger.info('[OK] Certificate saved to redis')
    end

    def private_path
      @private_path ||= Config.settings['private_path']
    end
  end
end
