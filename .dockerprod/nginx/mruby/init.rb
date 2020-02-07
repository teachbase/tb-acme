# frozen_string_literal: true

userdata = Userdata.new
userdata.redis = Redis.new(url: ENV['REDIS_URL'])
