workers 2

threads 1, 4

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

environment "production"

bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

# Set master PID and state locations
pidfile "#{shared_dir}/tmp/pids/puma.pid"
state_path "#{shared_dir}/tmp/pids/puma.state"
activate_control_app
