# frozen_string_literal: true

class AcmeRefresher
  def intializer(account_id)
    @account = Models::Account.find(account_id)
  end

  def perform
    return false if @account.nil?
    AcmeRegistrator.new(@account).perform
  end
end
