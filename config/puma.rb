workers 2

threads 1, 4

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

environment "production"

bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app
