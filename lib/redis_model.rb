require 'json'

class RedisModel
  class << self
    def find(id)
      data = $redis.get("account:#{id}")
      return unless data
      new(JSON.parse(data))
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
      $redis.set("account:#{id}", JSON.generate(as_json))
      $redis.save
      return true
    end
    false
  end

  def id
    0
  end

  def add_error(attribute, message)
    @errors[attribute] = message
  end

  def valid?
    errors.size == 0
  end
end
