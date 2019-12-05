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
      @order ||= client.new_order(identifiers: [account.domain])
      @resource.error(:order, "Order not created") unless @order
      @order
    end

    def authorization
      @authorization ||= order.authorizations.first
      @resource.error(:authorization, "Authorization not created") unless @authorization
      @authorization
    end

    def challenge
      @challenge ||= authorization.http
      @challenge.error(:authorization, "Http challenge failed") unless @challenge
      @challenge
    end
  end
end
