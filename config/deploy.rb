# frozen_string_literal: true

require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/puma'
require 'mina/whenever'
require 'yaml'

config = YAML.load_file("#{File.dirname(__FILE__)}/secrets.yml").fetch((ENV['RACK_ENV'] || 'production'), {})
set :user, config['username']
set :domain, config['deploy_host']
set :deploy_to, config['remote_path']
set :port, config['deploy_port']
set :repository, config['repository']
set :branch, ENV['BRANCH'] || "master"
set :shared_path, "#{config['remote_path']}/shared"
set :log_path, "#{config['remote_path']}/shared/log"
set :shared_files, ['config/secrets.yml', 'config/puma.rb']

task :preserve_logs => :environment do
  command %{mkdir -p "#{fetch(:log_path)}/archived_logs"}
  time = Time.now.strftime('%Y%m%d_%H_%M')
  command %{cp "#{fetch(:log_path)}/stdout" "#{fetch(:log_path)}/archived_logs/#{time}_stdout"}
  command %{cp "#{fetch(:log_path)}/stderr" "#{fetch(:log_path)}/archived_logs/#{time}_stderr"}
end

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
    invoke :preserve_logs
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    on :launch do
      invoke :'whenever:update'
      invoke :'puma:stop'
      invoke :'puma:start'
    end
  end
end
