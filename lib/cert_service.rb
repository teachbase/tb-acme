class CertService
  attr_reader :registrator

  def handle(data)
    account_id = data.fetch('id', 0)
          
    if account = Account.find(account_id)
      obtain_certificate(account)
    else
      register_account_and_obtain(data)
    end
  end

  private

  def obtain_certificate(account)
    CryptoRegistrator.new(account).obtain
  end

  def create_account(data)
    account = Account.new(data)
    account.private_key = OpenSSL::PKey::RSA.new(4096)
    account.save
    account
  end

  def register_account_and_obtain(data)
    registrator = CryptoRegistrator.new(create_account(data))
    registrator.register
    registrator.obtain
  end
end
