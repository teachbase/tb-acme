# frozen_string_literal: true

class CertService
  attr_reader :registrator

  # Handle params and creates/updates account, register and obtain cert.
  # Params:
  # +params+:: hash with account parameters {id, name, domain}
  def perform(params)
    register_account_and_obtain
  end

  private

  def register_account_and_obtain
    account = Models::Account.find_or_create_by(params)
    CryptoRegistrator.new(account).perform
  end
end
