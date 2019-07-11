class CertService
  attr_reader :registrator

  # Handle params and creates/updates account, register and obtain cert.
  # Params:
  # +data+:: hash with account parameters {id, name, domain}
  def handle(data)
    account = load_account(data)
    register_account_and_obtain(account)
  end

  private

  def create_account(data)
    account = Account.new(data)
    account.reset_private_key
    account.save
    account
  end

  def register_account_and_obtain(account)
    registrator = CryptoRegistrator.new(account)
    registrator.register
    # registrator.obtain # we already obtain in register?
  end

  def load_account(data)
    account = Account.find(data.fetch('id', 0))

    return create_account(data) if account.nil?

    new_host = data['domain']
    if new_host && !account.same_domain?(new_host)
      account.domain = new_host
    end
    account.reset_private_key
    account.save
    account
  end
end
