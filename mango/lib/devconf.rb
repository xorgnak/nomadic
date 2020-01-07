require 'sinatra/base'

class App < Sinatra::Base
  configure do
    set :port, 8080
    set :bind, "0.0.0.0"
    set :views, settings.root + "/../views"
  end
get('/') do
erb :index
end
post('/') do
redirect '/'
end
end

Process.detach( fork { App.run! } )
