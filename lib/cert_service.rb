# frozen_string_literal: true

class CertService
  attr_reader :registrator

  # Handle params and creates/updates account, register and obtain cert.
  # Params:
  # +params+:: hash with account parameters {id, name, domain}
  def handle(params)
    account = load_account(params)
    register_account_and_obtain(account)
  end

  def create_account(params)
    account = Models::Account.new(params)
    account.reset_private_key
    account.save
    account
  end

  private

  def register_account_and_obtain(account)
    CryptoRegistrator.new(account).perform
  end

  def load_account(params)
    account = Models::Account.find(params.fetch('id', 0))

    return create_account(params) if account.nil?

    new_host = params['domain']
    if new_host && !account.same_domain?(new_host)
      account.domain = new_host
    end
    account.reset_private_key
    account.save
    account
  end
end
