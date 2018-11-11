# frozen_string_literal: true

module Stages
  class Validation    
    def initialize(resource)
      @resource = resource
    end

    def call
      return @resource if @resource.invalid?

      dns_checking
      @resource
    end

    private

    def dns_checking
      return if Validations::DNS.new(@resource.account.domain).valid?
      @resource.error(:account, "DNS validation failed. Check account DNS settings")
    end
  end
end
