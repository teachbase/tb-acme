require "#{File.dirname(__FILE__)}/lib/quota"
require "#{File.dirname(__FILE__)}/lib/cert_expiration"
require "#{File.dirname(__FILE__)}/lib/cert_refresher"
require "#{File.dirname(__FILE__)}/lib/config"
require "#{File.dirname(__FILE__)}/lib/account"

require "./boot"

def load_all
  Boot.load
end

def rebuild_chain(account_id)
  account = Account.find(account_id)

  unless account
    puts "Error. Account with ID #{account_id} not found. Exit."
    return
  end

  puts "Rebuild certificate chain for: #{account.domain} "

  dir = Config.settings['private_path']
  cert_path = "#{dir}/#{account.domain}_fullchain.pem"

  unless File.exists?(cert_path)
    puts "Error: fullcain.pem does not exist. Exit."
    return
  end

  $redis.set("#{account.domain}.crt", File.read(cert_path))
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
    $logger.info("[ SCHEDULED JOB cert:refresh STARTS ]")
    account_ids = CertExpiration.today&.account_ids.to_a

    if account_ids.empty?
      $logger.info("[ SCHEDULED JOB cert:refresh NO ACCOUNTS TO REFRESH ]")
      return
    end

    account_ids.each do |account_id|
      $logger.info("[ SCHEDULED JOB cert:refresh CALL REFRESHER FOR #{account_id} ]")
      CertRefresher.new(account_id).update
    end
  end

  task :rebuild, [:id] do |_t, args|
    load_all
    rebuild_chain(args[:id])
  end

  task :rebuild_all do
    load_all
    account_ids = $redis.keys("Account*").map { |e| e.split(':').last }
    account_ids.each { |id| rebuild_chain(id) }
  end
end
