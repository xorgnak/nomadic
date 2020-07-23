require 'cinch'


def handle_message m
  puts "#{m}"
  return m
end

def handle_irc_message m, h={}
  handle_message(m.message)
end


@bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "Vx" + ONION[0..8]
    c.server = "irc.freenode.net"
    c.channels = ["#bc-DEN"]
  end
  on :connect do |m|
    Redis.new.subscribe("irc") do |on|
      on.message do |ch, m|
        Channel("#bc-DEN").send(m)
      end
    end
  end
  on :private do |m|
    handle_irc_message(m, private: true)
  end
  on :message do |m|
    handle_irc_message(m)
  end
end

def bot_start
  Process.detach( fork { @bot.start } )
end