# frozen_string_literal: true

require "ostruct"

module Stages
  class Resource
    extend Forwardable

    def initialize(client: , account:)
      @resource = OpenStruct.new(
        client:       client,
        account:      account,
        order:        nil,
        challenge:    nil,
        certificate:  nil,
        private_key:  nil,
        keyword_init: true,
        errors:       []
      )

      error(:account, "Account is nil") if account.nil?
    end

    def_delegators :@resource, :client, :account, :order, :challenge, :certificate,
                   :private_key, :keyword_init, :errors

    def valid?
      @resource.errors.empty?
    end

    def invalid?
      !valid?
    end

    def error(field, message)
      @resource.errors << { field => message }
    end
  end
end
