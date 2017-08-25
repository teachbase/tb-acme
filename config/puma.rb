require 'yaml'
require './lib/config'

workers 2

threads 1, 4

env = (ENV['RACK_ENV'] || 'production')

if env == 'production'
  config = YAML.load_file("#{File.dirname(__FILE__)}/secrets.yml").fetch(env, {})

  app_dir = File.expand_path("../..", __FILE__)
  shared_dir = "#{config['remote_path']}/shared"

  stdout_redirect "#{shared_dir}/log/stdout", "#{shared_dir}/log/stderr"
  environment env

  bind "unix://#{shared_dir}/tmp/sockets/puma.sock"
  pidfile "#{shared_dir}/tmp/pids/puma.pid"
  state_path "#{shared_dir}/tmp/pids/puma.state"
  activate_control_app
else
  environment "development"
  activate_control_app
end
