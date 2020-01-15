# frozen_string_literal: true

require 'acme-client'
require 'raven'

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
    handle_errors
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

  def handle_errors
    return unless @resource.invalid?

    $logger.info("[Errors] #{@resource.errors}")
    field, message = @resource.errors.first
    @resource.errors.each do |h|
      field = h.keys.first
      message = h[field]
      Raven.capture_message(
        message,
        tags: { type: 'ssl_cert_release_error' },
        extra: {
          field:      field,
          account_id: @account.id,
          domain:     @account.domain
        },
        level: 'error'
      )
    end
  end
end
