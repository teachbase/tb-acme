# frozen_string_literal: true

require 'yaml'
require './lib/config'

workers 2

threads 1, 4

env = (ENV['RACK_ENV'] || 'production')

if env == 'production'
  config = YAML.load_file("#{File.dirname(__FILE__)}/secrets.yml").fetch(env, {})
  app_dir = File.expand_path("../..", __FILE__)

  stdout_redirect "#{app_dir}/log/stdout", "#{app_dir}/log/stderr"
  environment env

  bind "unix://#{app_dir}/tmp/sockets/puma.sock"
  pidfile "#{app_dir}/tmp/pids/puma.pid"
  state_path "#{app_dir}/tmp/sockets/puma.state"
  activate_control_app "unix://#{app_dir}/tmp/sockets/pumactl.sock"
else
  environment "development"
end
