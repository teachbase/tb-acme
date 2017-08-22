require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/puma'
require 'yaml'

config = YAML.load_file("#{File.dirname(__FILE__)}/secrets.yml").fetch('production', {})
set :user, config['username']
set :domain, config['deploy_host']
set :deploy_to, config['remote_path']
set :repository, config['repository']
set :shared_path, "#{config['remote_path']}/shared"

task :setup => :environment do
  command %{mkdir -p "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/sockets"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/sockets"}
  command %{mkdir -p "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/pids"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/pids"}
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
