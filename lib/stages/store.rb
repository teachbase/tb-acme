# frozen_string_literal: true

module Stages
  class Store
    def new(resource)
      @resource = resource
    end

    def call
      write_to_filesystem
      write_to_account
      write_to_storage
      @resource
    end

    private

    def private_key_pem
      @resource.private_key.to_pem
    end

    def certificate
      @resource.certificate
    end

    def write_to_filesystem
      return if Dir.exists?(private_path)
      FileUtils.mkdir_p(private_path)
      File.write("#{private_path}/#{@resource.account.domain}.key", private_key_pem)
      File.write("#{private_path}/#{@resource.account.domain}.crt", certificate)
    end

    def write_to_account
      @resource.account.domain_cert = certificate
      @resource.account.domain_private_key = private_key_pem
      @resource.account.save
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
