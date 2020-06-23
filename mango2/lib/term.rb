require 'mqtt'
require 'base64'
require 'rqrcode'
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
  Redis.new.publish("MANGO.#{c}", p)
end 

class MangoWebConfig < Sinatra::Base
  def initialize
    super
    log "Starting in #{Dir.pwd}...", :notice
  end
  error do
    log "ERR: #{JSON.generate(env['sinatra.error'].message)}", :error
  end
  configure do
    set :server, 'thin'
    set :sockets, []
    set :port, 80
    set :bind, '0.0.0.0'
    set :root, Dir.pwd
    set :show_exceptions, :after_handler
#    set :views, File.dirname("/home/pi/nomadic/mango2/views/")
    enable :sessions
  end
  helpers do
    def handle_msg m, *to
      j = JSON.parse(m)
      if to[0]
        t = t[0]
      else
        t = "reply"
      end
      log ["to: #{t}", "j: #{j}"], :log
    end
    def msg **h
      Redis(JSON.generate({
                              color: h[:color] || "white",
                              msg: h[:msg],         
                              icon: h[:icon] || "message",
                              from: h[:from] || "server",
                              to: h[:to] || h[:from] || "server"
                            }))
      puts "MSG: #{h}"
    end
  end
  before do

    if Redis::Value.new('id').value == nil
      x = []; 6.times { x << rand(9) }
      Redis::Value.new('id').value = x.join('')
    end
    @id = Redis::Value.new('id').value

    if Redis::Value.new('odm').value == nil
      Redis::Value.new('odm').value = 0
    end                                                                     
    @odm = Redis::Value.new('odm').value.to_i
    
    if Redis::Value.new('name').value == nil
      x = ['albus', 'bravery', 'castle', 'devient', 'extreme']
      Redis::Value.new('name').value = 'the good van ' + x.sample
    end
    @name = Redis::Value.new('name').value

    if Redis::Value.new('ui').value == nil
      x = File.read("/var/lib/tor/services/hostname")
      Redis::Value.new('ui').value = "#{x}/ui"
      qrcode = RQRCode::QRCode.new("#{x}/ui", size: 4, level: :l)
      # NOTE: showing with default options specified explicitly          
      png = qrcode.as_png(               
        bit_depth: 1,          
        border_modules: 4,
        color_mode: ChunkyPNG::COLOR_GRAYSCALE,             
        color: 'black',                  
        file: nil,              
        fill: 'white',          
        module_px_size: 6,   
        resize_exactly_to: false,       
        resize_gte_to: false,                   
        size: 200                             
      )                                    
      File.open("public/ui.png", 'wb') {|f| f.write(png.to_s) }
    end
    @ui = Redis::Value.new('ui').value

    log ["REQ: #{request}", "PAR: #{params}", "id: #{@id}"
        ], :notice
  end
  get('/ui') do
    erb :ui
  end
  get('/u') do
    erb :user
  end
  get('/') do
    if !request.websocket?
      erb :index
    else
      request.websocket do |ws|
        ws.onopen do
          log "WS: OPEN", :notice
          ws.send(
            JSON.generate(
              {
                color: "white",
                msg: "connected.",
                icon: "network_check",
                from: "server",
                to: @id
              }
            )
          )
          settings.sockets << ws
          Redis.new.subscribe("ws") do |on|
            on.subscribe do |ch, subs|
              log "subscribe: #{ch}, #{subs}, #{settings.sockets}", :notice
            end
            on.message do |ch, m|
              log ["MSG:CH: #{ch} #{m}"], :notice
              EM.next_tick {
                settings.sockets.each{|s|
                  h = handle_msg(m, s)
                  if h[:send]
                    ws.send(
                      JSON.generate(
                        {
                          color: h[:color] || "white",
                          msg: h[:msg],
                          icon: h[:icon] || "message",
                          from: h[:from] || "server",
                          to: h[:to] || h[:from] || "server"                        
                        }
                      )
                    )
                  end
                }
              }
            end
            on.unsubscribe do |ch, subs|
              log "unsubscribe: #{ch}, #{subs}", :notice 
              settings.sockets.delete(ws)
            end
          end
        end
        ws.onmessage do |m|
          log ["MSG:WS: #{m}"], :notice
          handle_msg(m)
        end
        ws.onclose do
          log "[WS] closed", :notice
          settings.sockets.delete(ws)
        end
      end
    end
  end 
end

def mango h={}
  Process.detach(fork {
                   begin
                   w = MangoWebConfig;

#                   h.each_pair { |k,v| w.set(k, v) };
                   Redis.new.publish("MANGO.INIT", "#{Time.now}")
                   w.run!
                   rescue => e
                     Redis.new.publish("MANGO.ERROR", "#{JSON.generate(e)}")
                   ensure
                     Redis.new.publish("MANGO.EXIT", "#{Time.now}")
                     if ENV['REBOOT'] == true
                       Redis.new.publish("MANGO.REBOOT", "#{Time.now}")
                       `sudo reboot`
                     end
                   end
                 })
end
