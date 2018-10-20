# frozen_string_literal: true

require 'logger'

class Logger
  class << self
    %i(info waring error debug).each do |name|
      define_method(name) do |message|
        instance.log(name, message)
      end
    end

    private
    
    def instance
      @instance ||= ::Logger.new($stdout)
    end
  end
end
