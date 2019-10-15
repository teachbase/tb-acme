# frozen_string_literal: true

module Stages
  class Issue
    extend Forwardable

    TIMEOUT = 6
    EXPIRATION_OFFSET = 83

    def initialize(resource)
      @resource = resource
    end

    def_delegators :@resource, :order, :account, :challenge

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

    def waiting_ordered_certificate
      csr = create_csr

      order.finalize(csr: csr)

      counter = 0
      while order.status == 'processing'
        break if counter >= TIMEOUT
        sleep(1)
        counter += 1
        challenge.reload
      end

      $logger.info('[OK] Certificate issued successful')
      @resource.certificate     = order.certificate
      @resource.private_key_pem = csr.private_key.to_pem
      @resource
    end

    def set_certificate_expiration
      expiration_date = (Date.today + EXPIRATION_OFFSET).strftime('%d%m%y')
      cert_exp        = Models::CertExpiration.find(expiration_date)

      if cert_exp
        cert_exp.append(account.id)
      else
        ::Models::CertExpiration.new(id: expiration_date, account_ids: [account.id]).save
      end
    end

    def create_csr
      Acme::Client::CertificateRequest.new(
        private_key: OpenSSL::PKey::RSA.new(4096),
        subject: { common_name: account.domain }
      )
    end

    def valid?
      @resource.valid? && !challenge.nil? && challenge.status == 'valid'
    end
  end
end
