# frozen_string_literal: true

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
    @id || Date.today.strftime('%d%m%y')
  end

  def self.today
    find(Date.today.strftime('%d%m%y'))
  end

  def append(account_id)
    return if account_ids.include?(account_id.to_i)
    self.account_ids << account_id
    save
  end
end
