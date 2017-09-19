require "#{File.dirname(__FILE__)}/lib/quota"
require "#{File.dirname(__FILE__)}/lib/cert_expiration"
require "./boot"

def load_all
  Boot.load
end

namespace :quota do
  task :reset do
    load_all
    Quota.new.reset
  end
end

namespace :cert do
  task :refresh do
    load_all
    (CertExpiration.today&.account_ids || [])
      .each { |account_id| CertRefresher.new(account_id).update }
  end
end
