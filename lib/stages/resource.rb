# frozen_string_literal: true

require "ostruct"

module Stages
  Resource = Struct.new(
    :client,
    :account,
    :order,
    :challenge,
    :certificate,
    :private_key,
    keyword_init: true
  )

  def init(client: , account:)
    Resource.new(
      client: client,
      account: account,
      order: nil,
      challenge: nil,
      certificate: nil,
      private_key: nil
    )
  end
end
