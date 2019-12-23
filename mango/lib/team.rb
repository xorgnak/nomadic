class Team
  include Redis::Objects
  def initialize t
    @id = "team:#{t}"
  end
  def id; @id; end
  hash_key :attrs
  hash_key :titles
  set :users
  set :cab
  sorted_set :hits
  sorted_set :hit
end
