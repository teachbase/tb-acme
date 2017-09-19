require './account'
require './cert_expiration'

class CertRefresher
  def intializer(account_id)
    @account = Account.find(account_id)
  end

  def update
    return false if @account.nil?
    reg = CryptoRegistrator.new(@account)
    
    begin
      reg.obtain
    rescue => e
      reg.register
      reg.obtain
    end 
  end
end
