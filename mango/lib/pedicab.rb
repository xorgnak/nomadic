class Cab < User
  include Redis::Objects
  sorted_set :users
  sorted_set :games
  sorted_set :rewards
end
