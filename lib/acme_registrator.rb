# frozen_string_literal: true

require 'acme-client'

class AcmeRegistrator
  CONNECTION_OPTIONS = {
    request: {
      open_timeout: 20,
      timeout:      20
    }
  }.freeze

  def initialize(account)
    @account = account
  end

  def perform
    @resource = Stages::Resource.new(client: client, account: @account)
    @resource = Stages::Validation.new(@resource).call
    @resource = Stages::Registration.new(@resource).call
    @resource = Stages::Order.new(@resource).call
    @resource = Stages::Verification.new(@resource).call
    @resource = Stages::Issue.new(@resource).call
    @resource = Stages::Store.new(@resource).call
    $logger.info("[Errors] #{@resource.errors}") if @resource.invalid?
    @resource
  end

  private

  def client
    @client ||= Acme::Client.new(
      kid:                @account.kid,
      private_key:        OpenSSL::PKey.read(@account.private_key.to_s),
      directory:          Config.settings['acme_endpoint'],
      connection_options: CONNECTION_OPTIONS
    )
  end
end
