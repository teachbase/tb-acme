class Quota
  REDIS_KEY = 'cert:week:count'.freeze
  QUOTA_SIZE = 20

  def get; counter; end

  def decr
    if available?
      decrement
    else
      reset && return decrement
    end
  end

  def reset
    $redis.set(REDIS_KEY, QUOTA_SIZE)
    @counter = nil
    counter
  end

  def available?
    counter > 0
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
