# frozen_string_literal: true

module Stages
  class Issue
    def initialize(resource)
      @resource = resource
    end

    def call
      unless valid?
        @resource.error(:challenge, 'Challenge does not exists or status is NOT VALID')
        return @resource
      end

      waiting_ordered_certificate
      set_certificate_expiration
      @resource
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
      
      $logger.info('[OK] Certificate issued successful')
      @resource.certificate = order.certificate
      @resource.private_key = csr.private_key
      @resource
    end

    def set_certificate_expiration
      expiration_date = (Date.today + EXPIRATION_OFFSET).strftime('%d%m%y')

      if cert_exp = Models::CertExpiration.find(expiration_date)
        cert_exp.append(account.id)
      else
        ::Models::CertExpiration.new(id: expiration_date, account_ids: [account.id]).save
      end
    end

    def create_csr
      Acme::Client::CertificateRequest.new(
        private_key: OpenSSL::PKey::RSA.new(4096),
        subject: { common_name: @resource.account.domain }
      )
    end

    def valid?
      @resource.valid? && !@resource.challenge.nil? && @resource.challenge.status == 'valid'
    end
  end
end
