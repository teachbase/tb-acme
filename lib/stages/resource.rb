# frozen_string_literal: true

module Stages
  class Resource
    attr_accessor :client, :account, :order, :challenge, :certificate,
                  :private_key, :keyword_init, :errors

    def initialize(client: , account:)
      @client       = client
      @account      = account
      @order        = nil
      @challenge    = nil
      @certificate  = nil
      @private_key  = nil
      @keyword_init = true
      @errors       = []

      error(:account, "Account is nil") if account.nil?
    end

    def valid?
      errors.empty?
    end

    def invalid?
      !valid?
    end

    def error(field, message)
      errors << { field => message }
    end
  end
end
