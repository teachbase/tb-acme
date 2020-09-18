#!/usr/bin/env puma

# frozen_string_literal: true

require 'yaml'
require './lib/config'

bind 'tcp://0.0.0.0:9292'
workers 2
threads 1, 4

env = (ENV['RACK_ENV'] || 'production')

if env == 'production'
  config = YAML.load_file("#{File.dirname(__FILE__)}/secrets.yml").fetch(env, {})
  app_dir = File.expand_path('..', __dir__)

  rackup "#{app_dir}/config.ru"
  directory app_dir
  environment env

  pidfile "#{app_dir}/tmp/pids/puma.pid"
  state_path "#{app_dir}/tmp/sockets/puma.state"
else
  environment 'development'
end
