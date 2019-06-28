require './lib/account'
require './lib/cert_expiration'

class CertRefresher
  def intializer(account_id)
    @account = Account.find(account_id)
  end

  def update
    return false if @account.nil?
    reg = CryptoRegistrator.new(@account)

    # We must register account again
    # because Letsencrypt will store info only 1 month
    reg.register
    reg.obtain
  end
end
