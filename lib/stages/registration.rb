# frozen_string_literal: true

module Stages
  class Registration
    def initialize(resource)
      @resource = resource
    end

    def call
      return @resource if @resource.invalid?

      $logger.info("[Registration] called for owner #{owner_email}")
      registered = client.new_account(contact: owner_email, terms_of_service_agreed: true)
      @resource.error(:account, "Account regsitration failed") unless registered.kid
      @resource.account.kid = registered.kid
      @resource
    end

    private

    def client
      @resource.client
    end

    def owner_email
      Config.settings['owner_email']
    end
  end
end
