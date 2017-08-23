require 'yaml'

workers 2

threads 1, 4

env = (ENV['RACK_ENV'] || 'production')
config = YAML.load_file("#{File.dirname(__FILE__)}/secrets.yml").fetch(env, {})

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{config['remote_path']}/shared"

environment env

bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

# Set master PID and state locations
pidfile "#{shared_dir}/tmp/pids/puma.pid"
state_path "#{shared_dir}/tmp/pids/puma.state"
activate_control_app
