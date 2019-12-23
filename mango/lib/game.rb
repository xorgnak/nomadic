class Game
  def initialize 
    i = []; 10.times { i << rand(16).to_s(16) }
    @id = i.join('')
    @game = {teams:{}, players: {}}
    @u = {}
    @log = []
    @state = "Ready to join!"
  end
  def play!
    @state = "In Prgress..."
  end
  def end!
    @state = "Done."
  end
  def add team, player, *r
    if @game[:teams][team]

    else
      
    end
  end
  def role player, r
    @users[player] = r
  end
  def user u
    @users[u]
  end
  
  def incr k
    @stats[k] += 1
  end
  def decr k
    @stats[k] -= 1
  end
  def to_h
    scores = Hash.new { |h,k| h[k] = 0 }
    @teams.each_pair { |t,v| v.each_pair { |p, s|
                         scores[t] += s
                       } }
    {
                    game: @id,
                    state: @state,
                    scores: scores,
                    users: @users,
                    stats: @stats
    }
  end
  def to_json
    JSON.generate(to_h)
  end
end
