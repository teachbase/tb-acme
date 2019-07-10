require './lib/account'
require './lib/cert_expiration'
require './lib/crypto_registrator'

class CertRefresher
  def initialize(account_id)
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

  def log(event_name, *params)
    logger = Logger.new('/webapps/tb_acme/shared/log/stdout')
    logger.info("[#{event_name}, #{Time.now} ]")
  end
end
