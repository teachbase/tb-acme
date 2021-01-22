# frozen_string_literal: true

set :environment, ENV['RACK_ENV']
set :output, error: '/var/log/error.log', standard: '/var/log/cron.log'

env 'GEM_HOME', ENV['GEM_HOME']
env 'BUNDLE_PATH', ENV['GEM_HOME']
env 'BUNDLE_APP_CONFIG', ENV['BUNDLE_PATH']
env 'BUNDLE_BIN', "#{ENV['BUNDLE_PATH']}/bin"
env 'PATH', ENV['PATH']

if ENV['APP_ROLE'] == 'master'
  every 1.day, at: '11:00pm' do
    rake 'cert:refresh'
  end
else
  every 1.day, at: '03:00am' do
    rake 'cert:refresh'
  end
end
