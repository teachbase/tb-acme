# frozen_string_literal: true

require 'json'

module Models
  class RedisModel
    class << self
      def find(id)
        data = $redis.get("#{self.demodulized_name}:#{id}")
        return unless data

        new(JSON.parse(data))
      end

      def demodulized_name
        self.name.split('::').last
      end

      def set_attributes(*attrs)
        @attributes = []
        @attributes.concat attrs
        attr_accessor *attrs
      end

      def attributes
        @attributes || []
      end
    end

    set_attributes :id

    attr_accessor :errors

    def initialize(attrs = {})
      @errors = {}
      attrs.each do |attr, value|
        _method = "#{attr}="
        public_send(_method, value) if respond_to?(_method)
      end
    end

    def as_json
      data = {}
      self.class.attributes.each do |attr|
        data[attr] = public_send(attr) if respond_to?(attr)
      end
      data
    end

    def save
      if valid?
        $redis.set(stored_key, JSON.generate(as_json))
        $redis.save unless cloud_redis?
        return true
      end
      false
    rescue ::Redis::CommandError => e
      raise unless e.message =~ /save already in progress/
      true
    end

    def id; 0; end

    def add_error(attribute, message)
      @errors[attribute] = message
    end

    def valid?
      errors.size == 0
    end

    private

    def model_name
      self.class.demodulized_name
    end

    def stored_key
      "#{model_name}:#{id}"
    end

    def cloud_redis?
      Config.settings['cloud_redis']
    end
  end
end
