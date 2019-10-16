# frozen_string_literal: true

module Stages
  class Order
    extend Forwardable

    def initialize(resource)
      @resource = resource
    end

    def_delegators :@resource, :client, :account

    def call
      return @resource if @resource.invalid?

      $logger.info("[Certificate order start] domain #{account.domain}")
      @resource.account.auth_uri = authorization.url
      @resource.order            = order
      @resource.challenge        = challenge
      @resource
    end

    private

    def order
      $logger.info("[Certificate order creating] domain #{account.domain}")
      @order ||= client.new_order(identifiers: [account.domain])
      $logger.info("[Certificate order created] domain #{account.domain}")
      @order
    end

    def authorization
      $logger.info("[Certificate order authorization] domain #{account.domain}")
      @authorization ||= order.authorizations.first
      $logger.info("[Certificate order authorization] domain #{account.domain} authorization #{@authorization}")
      @authorization
    end

    def challenge
      $logger.info("[Certificate challenge creating] domain #{account.domain}")
      @challenge ||= authorization.http
      $logger.info("[Certificate challenge created] domain #{account.domain} authorization #{@challenge}")
      @challenge
    end
  end
end
