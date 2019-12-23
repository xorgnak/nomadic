class User
  include Redis::Objects
  def initialize u
    @id = u
  end
  def id
    @id
  end
  hash_key :attrs
  sorted_set :stats
  sorted_set :hits
  sorted_set :hit
  def to_h
    { attrs: attrs.all, stats: stats.members(with_scores: true).to_h }
  end
  def to_json
    JSON.generate( to_h )
  end
end
