require 'tw'

class TwitterClient
  def initialize
    @twitter = Tw::Client.new
    @twitter.auth CONF['TWITTER_USER']
  end
  def [] k
    @twitter.search k
  end
  def tweet m
    @twitter.tweet m
  end
  def twitter
    @twitter
  end
end

@learning = {}
## listen
# stream twitter for a particular subject and add feed to stats[:main].
def listen f
  @learning[f] = Process.detach( fork {
                    t = Tw::Client::Stream.new
                    t.filter(f, language: 'english') { |m| stats[:main].tag(m.text.downcase) }
                  }
                )
end

## twitter
# twitter.tweet 'msg' => send a new tweet.
# twittr['query'] => search twitter on a subject.
def twitter
  TwitterClient.new
end
