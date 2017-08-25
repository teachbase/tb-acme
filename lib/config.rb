require 'yaml'

class Config
  def initialize
    env = ENV['RACK_ENV'] || 'production'
    @settings = YAML.load_file("#{File.dirname(__FILE__)}/../config/secrets.yml").fetch(env, {})
  end

  def settings
    @settings
  end

  def self.settings
    @settings ||= new.settings
  end
end
