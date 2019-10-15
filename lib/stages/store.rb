# frozen_string_literal: true

module Stages
  class Store
    extend Forwardable

    def initialize(resource)
      @resource = resource
    end

    def_delegators :@resource, :certificate, :account, :private_key_pem

    def call
      return @resource if @resource.invalid?

      write_to_filesystem
      write_to_account
      write_to_storage
      @resource
    end

    private

    def write_to_filesystem
      return if Dir.exists?(private_path)

      FileUtils.mkdir_p(private_path)
      File.write("#{private_path}/#{account.domain}.key", private_key_pem)
      File.write("#{private_path}/#{account.domain}.crt", certificate)
    end

    def write_to_account
      account.domain_cert        = certificate
      account.domain_private_key = private_key_pem
      account.save
    end

    def write_to_storage
      $redis.set("#{account.domain}.crt", certificate)
      $redis.set("#{account.domain}.key", private_key_pem)
    end

    def private_path
      @private_path ||= Config.settings['private_path']
    end
  end
end
