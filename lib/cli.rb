require 'json'
require 'redis'

@r = Redis.new

def pub c, h={}
  @r.publish(c, h.to_json)
end
