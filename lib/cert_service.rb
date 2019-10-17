# frozen_string_literal: true

class CertService
  # Handle params and creates/updates account, register and obtain cert.
  # Params:
  # +params+:: hash with account parameters {id, name, domain}
  def perform(params)
    account = Models::Account.find_or_create_by(params)
    AcmeRegistrator.new(account).perform
  end
end
