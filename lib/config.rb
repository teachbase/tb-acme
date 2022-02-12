# frozen_string_literal: true

require 'yaml'
require 'erb'

class Config
  def initialize
    env = ENV['RACK_ENV'] || 'production'
    @settings = YAML.load(ERB.new(File.read("#{__dir__}/../config/secrets.yml")).result).fetch(env, {})
  end

  def settings
    @settings
  end

  def self.settings
    @settings ||= new.settings
  end

  def self.settings=(hash = {})
    @settings.merge(hash)
  end
end
