require './lib/account'
require './lib/cert_expiration'

class CertRefresher
  def intializer(account_id)
    log("REFRESHING FOR ID #{account_id} STARTS")
    @account = Account.find(account_id)
  end

  def update
    if @account.nil?
      log('REFRESHING CANCELED ACCOUNT NOT FOUND')
      return false
    end
    reg = CryptoRegistrator.new(@account)

    # We must register account again
    # because Letsencrypt will store info only 1 month
    reg.register
    reg.obtain
  end
end
