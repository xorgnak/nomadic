require 'cinch'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.net"
    c.channels = ["#bc-DEN"]
  end

  on :message do |m|
    Redis.publish "irc", "#{m.methods}"
  end
end

bot.start
