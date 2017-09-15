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
set :shared_paths, ['config/secrets.yml']

task :setup => :environment do
  command %{mkdir -p "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/sockets"}
  command %{mkdir -p "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/tmp/pids"}
end

task :config_symlink => :environment do
  command %{rm -rf "#{fetch(:deploy_to)}/config"}
  command %{ln -s "#{fetch(:deploy_to)}/#{fetch(:shared_path)}/config" "#{fetch(:deploy_to)}/config"}
end

task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    
    on :launch do
      # invoke :'puma:phased_restart'
    end
  end
end
