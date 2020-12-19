# frozen_string_literal: true

userdata = Userdata.new
userdata.redis = Redis.new "redis", 6379, 0
