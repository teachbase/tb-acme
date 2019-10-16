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

      $logger.info("[Certificate order] domain #{account.domain}")
      @resource.account.auth_uri = authorization.url
      @resource.order            = order
      @resource.challenge        = challenge
      @resource
    end

    private

    def order
      @order ||= client.new_order(identifiers: [account.domain])
    end

    def authorization
      @authorization ||= order.authorizations.first
    end

    def challenge
      @challenge ||= authorization.http
    end
  end
end
