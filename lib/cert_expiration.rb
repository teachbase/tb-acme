require 'date'
require './lib/redis_model'

class CertExpiration < RedisModel
  REDIS_KEY_PREFIX = "cert:expire"

  set_attributes :id, :account_ids

  def initialize(*attrs)
    super
    @account_ids ||= []
  end

  def id
    Date.today.strftime('%d%m%y')
  end

  def self.today
    find Date.today.strftime('%d%m%y')
  end
end
