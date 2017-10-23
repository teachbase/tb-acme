class CertService
  attr_reader :registrator

  # Handle params and creates/updates account, register and obtain cert.
  # Params:
  # +data+:: hash with account parameters {id, name, domain}

  def handle(data)
    account = Account.find(data.fetch('id', 0))
    new_host = data['domain']

    unless account
      return register_account_and_obtain(create_account(data))
    end

    if new_host && !account.same_domain?(new_host)
      account.domain = new_host
      account.save
      
      register_account_and_obtain(account)
    else
      register_account_and_obtain(account)      
    end
  end

  private

  def create_account(data)
    account = Account.new(data)
    account.private_key = OpenSSL::PKey::RSA.new(4096)
    account.save
    account
  end

  def register_account_and_obtain(account)
    registrator = CryptoRegistrator.new(account)
    registrator.register
    registrator.obtain
  end
end
