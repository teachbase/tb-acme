require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/puma'
require 'yaml'

config = YAML.load_file('./secrets.yml').fetch('production', {})

set :user, config['username']
set :domain, config['host']
set :deploy_to, config['remote_path']
set :repository, config['repository']

task :setup => :environment do
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/sockets")
  queue! %(mkdir -p "#{deploy_to}/#{shared_path}/tmp/pids")
  queue! %(chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp/pids")
end

task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'bundle:install'

    on :launch do
      invoke :'puma:phased_restart'
    end
  end
end
