# clerk watches the nomadic channel for messages to the nomadic channel and sends appends a line in the user's index.org file accordingly.
require 'redis'
require 'json'

def make_org_heading h={'status' => '', 'heading' =>'', 'tags' => [], 'body' => ''}
  if h['tags'] != []
    @tags = ":#{h['tags'].join(':')}:"
  else
    @tags = ''
  end
  if h['status'] != ''
    @status = "#{h['status'].upcase} "
  else
    @status = ''
  end
  return "* #{@status}#{h['heading']}\t\t\t\t#{@tags}\n#{h['body']}\n"
end

redis = Redis.new
redis.subscribe('#clerk') do |on|
  on.subscribe do |ch, subs|

  end
  on.message do |ch, msg|
    @d = JSON.parse(msg)
    @d['users'].each { |u| File.open("/home/#{u}/index.org", 'a') { |f| f.write(make_org_heading(@d)) } }
  end
  on.unsubscribe do |ch, subs|

  end
end
