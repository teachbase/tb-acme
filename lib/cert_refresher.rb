# frozen_string_literal: true

require './lib/account'
require './lib/cert_expiration'
require './lib/crypto_registrator'

class CertRefresher
  def initialize(account_id)
    $logger.info("[ REFRESHING FOR ID #{account_id} STARTS ]")
    @account = Account.find(account_id)
  end

  def update
    if @account.nil?
      $logger.info('[ REFRESHING CANCELED ACCOUNT NOT FOUND ]')
      return false
    end

    reg = CryptoRegistrator.new(@account)
    return if reg.obtain

    reg.register
  end
end
