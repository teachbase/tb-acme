# frozen_string_literal: true

require 'acme-client'

class AcmeRegistrator
  CONNECTION_TIMEOUT = 20

  def initialize(account)
    @account = account
    @resource = Stages::Resource.init(client: client, account: account)
  end

  def perform
    if Validations::DNS.new(@resource.account.domain).valid?
      Logger.error('DNS validation failed')
      return
    end

    @resource = Stages::Registration.new(@resource).call
    @resource = Stages::Order.new(@resource).call
    @resource = Stages::Verification.new(@resource).call
    @resource = Stages::Store.new(@resource).call
    @resource
  end
  
  private

  def client
    @client ||= Acme::Client.new(
      kid: @account.kid,
      private_key: OpenSSL::PKey.read(@account.private_key.to_s),
      directory: Config.settings['acme_endpoint'],
      connection_options: { request: { open_timeout: CONNECTION_TIMEOUT, timeout: CONNECTION_TIMEOUT } }
    )
  end
end
