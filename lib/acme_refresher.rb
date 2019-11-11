# frozen_string_literal: true

class AcmeRefresher
  def initialize(account_id)
    @account_id = account_id
    @account    = Models::Account.find(account_id)
  end

  def perform
    if @account.nil?
      $logger.info("[Error] Account with id #{@account_id} not found")
      return false
    end
    AcmeRegistrator.new(@account).perform
  end
end
