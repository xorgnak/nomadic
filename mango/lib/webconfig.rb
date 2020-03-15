require 'sinatra/base'
require 'sinatra-websocket'
require 'redis-objects'

def log i, *a
  if i.class == String
    p = ERB.new(i).result(binding)
  elsif i.class == Array
    x = []
    i.each { |e| x << ERB.new(e).result(binding) }
    p = JSON.generate(x)
  else
    p = JSON.generate(i)
  end
  if a[0]
    c = a[0]
  else
    c = ''
  end
  Redis.new.publish("log.#{c}", p)
end 
def user u
  Redis::HashKey.new("users:#{u}")                                                                                                      
end

class WebConfig < Sinatra::Base
  class Op
    def initialize h={}
      @env = h
      @ops = {}
      @user = ""
      self.instance_eval(File.read("config.rb"))
    end
    def on(k, &b)
      @ops[k] = b
    end
    def for i
      xxx = false
      puts "i: #{i}"
      if /\d{10}/.match(i)
        @user = i
        j = { user: session_for }
        m = "user"
      elsif /^\{/.match(i)
        j = JSON.parse(i)
        m = "json"
      else
        j = {}
        m = i
      end
      if j[:user]
        if levelup? j[:user]
          levelup j[:user]
        end
      end
      @ops.each_pair do |k, b|
        if k.match(m)
         xxx = b.call(j).each_pair { |k,v| j[k] = v }
        end                                                                                
      end
      if xxx != false
        rxt = "xxx"
        rx = xxx
      else
        rxt = "turn"
        rx = @turn.call(j)
      end
      log ["rxt: #{rxt}", "rx: #{rx}"], :notice
      return rx
    end
  end
  def initialize
    super
    log "Starting in #{Dir.pwd}...", :notice
  end
  configure do
    set :server, 'thin'
    set :sockets, []
    set :port, 80
    set :bind, '0.0.0.0'
    set :root, Dir.pwd
    enable :sessions
  end
  helpers do
    def msg m, h={}                                                  
      x = Op.new h                                          
      return JSON.generate(x.for(m))
    end
  end
  before do
    @session = session
  end
  get('/:pg')do
    if params[:pg] == "favicon.ico"
      return ''
    elsif File.exist? "public/#{params[:pg]}"
      return File.read "public/#{params[:pg]}"
    else
      erb params[:pg].to_sym, layout: false
    end
  end
  post('/') do
    to = '/'
    log "post: #{params}", :notice
    return JSON.generate(x)
  end
  get '/' do
    log ["REQ: #{request}", "PAR: #{params}"], :notice
    if !request.websocket?
      erb :index
    else
      request.websocket do |ws|
        ws.onopen do
          log "WS: OPEN", :notice
          ws.send("Enter phone number to continue...")
          settings.sockets << ws
          Redis.new.subscribe("ws") do |on|
            on.subscribe do |ch, subs|
              log "subscribe: #{ch}, #{subs}", :notice
            end
            on.message do |ch, m|
              x = msg(m)
              log ["MSG:CH: #{ch} #{m}", "X: #{x}"], :notice
              if x != nil
                puts "WS: #{x}"
                EM.next_tick { settings.sockets.each{|s| s.send(x) } }
              end
            end
            on.unsubscribe do |ch, subs|
              settings.sockets.delete(ws)
            end
          end
        end
        ws.onmessage do |m|
          x = msg(m)
          log ["MSG:WS: #{m}", "X: #{x}"], :notice
          if x != nil
            Redis.new.publish("ws", x)
          end
        end
        ws.onclose do
          log "[WS] closed", :notice
          warn("websocket closed")
          settings.sockets.delete(ws)
        end
      end
    end
  end 
end

def webconfig h={}
  Process.detach(fork { w = WebConfig; h.each_pair { |k,v| w.set(k, v) }; w.run! })
end
