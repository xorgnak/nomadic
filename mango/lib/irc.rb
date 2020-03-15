require 'cinch'


def handle_message m
  @mh = { raw: m, words: @words }
  @words = m.split(" ")
  if /(.+):/.match(@words[0])
    c = @words[0].gsub(':','')
    @words.shift
    @mh[:cmd] = { input: c, words: @words }
  end
  return @mh
end

def handle_irc_message m, h={}
  @from = User.new(m.user.nick)
  @from.stats.incr('messages')
  @from.attrs[:last] = m.message
  @from.attrs[:seen] = Time.now.to_i
  @from.attrs[:in] = m.channel
  @room = Room.new(m.channel)
  @room.attrs[:last] = m.message
  @room.seen[m.user.nick] = Time.now.to_i
  @room.messages.incr(m.user.nick)
  "#{handle_message(m.message)} #{@from.attrs.all}"
end

class Room
  include Redis::Objects
  def initialize r
    @id = r
  end
  def id
    @id
  end
  hash_key :seen
  hash_key :attrs
  sorted_set :stats
  sorted_set :messages
end

@bot = Cinch::Bot.new do
  configure do |c|
    c.nick = ONION[0..8]
    c.server = "irc.freenode.net"
    c.channels = ["#bc-DEN"]
  end
  on :private do |m|
    m.reply handle_irc_message(m, private: true)
  end
  on :message do |m|
    m.reply handle_irc_message(m)
  end
end

#def bot_start
  @bot.start
#end
