class Quota
  REDIS_KEY = 'cert:week:count'.freeze
  LIMIT = 20

  def initialize
    reset if counter.nil?
  end

  def get; counter; end

  def decr
    if available?
      decrement
    else
      reset
      reload
      decrement
    end
  end

  def reset
    $redis.set(REDIS_KEY, LIMIT)
    @counter = nil
    counter
  end

  def available?
    counter.to_i > 0
  end

  def reload
    @counter = $redis.get(REDIS_KEY)
    self
  end

  private

  def counter
    @counter ||= $redis.get(REDIS_KEY)
    @counter ? @counter.to_i : nil
  end

  def decrement
    val = counter - 1
    $redis.set(REDIS_KEY, val)
    val
  end
end
