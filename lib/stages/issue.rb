# frozen_string_literal: true

module Stages
  class Issue
    def initialize(resource)
      @resource = resource
    end

    def call
      return false unless valid?
      waiting_ordered_certificate
      save_certificate
    end

    private

    def order
      @resource.order
    end

    def account
      @resource.account
    end

    def waiting_ordered_certificate
      csr = create_csr
  
      order.finalize(csr: csr)
      sleep(1) while order.status == 'processing'
      
      Logger.log('[OK] Certificate issued successful', order.certificate)
      @resource.certificate = order.certificate
      @resource.private_key = csr.private_key
      @resource
    end

    def create_csr
      Acme::Client::CertificateRequest.new(
        private_key: OpenSSL::PKey::RSA.new(4096),
        subject: { common_name: @resource.account.domain }
      )
    end

    def valid?
      @resource.challenge.status == 'valid'
    end
  end
end
