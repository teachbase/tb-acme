# frozen_string_literal: true

require './lib/models/account'
require './lib/models/cert_expiration'

class CertRefresher
  def intializer(account_id)
    @account = Models::Account.find(account_id)
  end

  def update
    return false if @account.nil?
    CryptoRegistrator.new(@account).perform
    
    # We must register account again
    # because Letsencrypt will store info only 1 month
    reg.register
    reg.obtain
  end
end
