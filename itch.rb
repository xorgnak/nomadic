require 'sinatra/pubsub'
require 'rb-inotify'
require 'cinch'
require 'tilt/erb'
require 'redis-objects'
require 'digest'
require 'json'
require 'gmail'
require 'sinatra'
require 'uri'
require 'thin'
require 'rdoc'

register Sinatra::PubSub
include Redis::Objects
$theme = { :base => '#fff', :main => '#000', :accent => '#f00' }
$std_head = [
             '<meta name="viewport" content="initial-scale=1, maximum-scale=1">'
            ]

begin
  
  def init!
    $svcs = {}
    $tmpl ={}
    reset_db!
    ARGF.argv.each do |lib|
      if File.exist? lib
        puts "Loading #{lib}..."
        load lib
      end
    end
    puts "Ready to start the App server."
  end
  
  def svc c, &b
    @r, @b = Redis.new, b
    $svcs[c] = Process.detach(
                              fork do
                                @r.subscribe(c) do |on|
                                  on.message do |ch, m|
                                    @h = JSON.parse(m)
                                    @b.call(@h)
                                  end
                                end
                              end
                              )
    puts "Started #{c} service."
    reset_db!
  rescue
    exit!
  end
  
  def publish_to_svc s, h={}
    @r = Redis.new
    @r.publish s, JSON.generate(h)
  end
  
  def tmpl n, *e
    if e[0] != nil
      $tmpl[n] = e[0]
      puts "Created #{n} template."
    else
      return $tmpl[n]
    end
  end
  
  def reset_db!
    @db = Redis.new
  end
  
  init!
  
  configure do
    set :port, PORT || 80
    set :bind, '0.0.0.0'
    set :session_secret, SECRET || Digest::SHA2.hexdigest(rand(2147483647).to_s(16))
    set :public_dir, '/var/www'
    set :app, {}
    set :svc, {}
    set :sessions, {}
    set :locked, false
    set :debug, true
    set :notification, ''
    set :post_params, true
    use Rack::Deflater
  end
  
  helpers do
    def construct
      if settings.locked == false
        @c = []
        @c << "#construct { width:auto; background-color: #{$theme[:base]}; color: #{$theme[:main]}; border-radius: 10px; border-width: 2px; border-style: solid; border-color: #{$theme[:main]}; padding: 12px; }"
        @c << "#notification { padding-top: 5px; color: #{$theme[:accent]}; }"
        @c << "#hud {text-align: center; }"
        @c << "#input { border-radius: 5px; width: 100%; }"
        @c << "#muon { width: 100%; }"
        @o = ["<style>#{@c.join('')}</style>",
              "<form id='construct' method='post' action='/'>",
              "<input type='text' name='muon'>",
              "<input type='hidden' name='path' value='<%= @path %>'>",
              "<p><input type='submit' value='<<<'></p></div>",
              %[<div id='notification'>#{settings.notification}</div>],
              "<code>#{settings.app}</code>",
              '</form>']
        return ERB.new(@o.join('')).result(binding)
      else
        return ''
      end
    end
    
    def map_template_to_route *t
      t.each do |tp|
        @a = settings.app["/#{tp}"] = {}
        @a[:script] = [ tmpl(tp) ]
      end
    end
    
    def map_route_to_template r,t
      @a = settings.app[r] = {}
      @a[:script] = [ tmpl(t) ]
    end
    
    def lock l
      settings.locked = l
    end
    
    def clear!
      settings.notification = "Clear!"
      settings.app[@path] = {}
    end
    def safe s
      s.gsub('&','&amp').gsub('<','&lt').gsub('>','&gt')
    end
    
    def scriptable? s
      case
      when /lock .+/.match(s)
        return false
      when /debug .+/.match(s)
        return false
      when /scriptable? s/.match(s)
        return false
      when /authorize .+ .+ .+/.match(s)
        return false
      when /post.*/.match(s)
        return false
      when /man/.match(s)
        return false
      when /publish.*/.match(s)
        return false
      when /clear!/.match(s)
        return false
      when /glyph.*/.match(s)
        return false
      when /tmpl.*/.match(s)
        return false
      when /map_template_to_route.*/
        return false
      else
        return true
      end
    end
    
    def app c, *i
      if settings.app[@path][c] == nil
        settings.app[@path][c] = []
      end
      if i[0] == nil
        settings.app[@path][c].flatten!
        settings.app[@path][c].uniq!
        case
        when c == :css
          @o = "<style>#{settings.app[@path][c].join('')}</style>"
        when c == :form
          @o = "<form enctype='multipart/form-data' method='post' action='/'>#{settings.app[@path][c].join('')}</form>"
        when c == :script
          @o = "#{settings.app[@path][c].join(';')}"
        when c == :js
          @o = "<script>#{settings.app[@path][c].join('')}</script>"
        else
          @o = "#{settings.app[@path][c].join('')}"
        end
        return ERB.new(@o).result(binding)
      else
        settings.notification = "#{c} updated."
        i.each {|e| settings.app[@path][c] << e }
      end
    end
    def crumb c={}
      @c = []
      c.each_pair { |k, v| @c << "<a class='crumb' href='/#{v}'>#{k}</a>" }
      app :form, "<div id='crumbs'>#{@c.join('')}</div>"
      app :css, "#crumbs {float:right; font-size: 250%;}"
    end
    
    def qrcode uri
      @u = URI.encode(uri)
      @i = Digest::SHA2.hexdigest(@u)
      if !File.exist?("/var/www/#{@i}.png")
        `qrencode -o /var/www/#{@i}.png #{@u}`
      end
      app :body, "<img id='qrcode' src='/#{@i}.png'>"
    end
    
    def cd k
      @goto = k
    end
    
    def goto k
      app :form, "<input type='hidden' name='goto' value='#{k}'>"
    end
    ##                                                                                                                                                                 
    # :section: Form                                                                                                                                                    
    # Set a hidden input, +k+ to +v+.                                                                                                                                  
    def hidden k, v
      app :form, "<input type='hidden' name='#{k}' value='#{v}'>"
    end
    ##                                                                                                                                           
    # :section: Form                                                                                                                                            
    # Add a text area of +n+                                                                                                   
    def textareainput n
      app :css, "textarea { width: 100%; }"
      app :form, "<textarea placeholder='#{n.to_s}' name='#{n.to_s}'></textarea>"
    end
    def editorinput n, f
      if !File.exist? f
        File.open(f) {|f| f.write(""); }
      end
      @f = "<%= File.read('#{f}') %>"
      app :css, "textarea { width: 100%; }"
      app :form, "<textarea placeholder='#{n.to_s}' name='#{n.to_s}'>#{@f}</textarea>"
    end
    ##                                                                                                                                                                    
    # :section: App                                                                                                                                                       
    # Round the +form+ input elements.                                                                                                                                    
    def rounded
      app :css, "input { width: auto; border-radius: 10px; }"
    end
    ##                                                                                                                                                                    
    # :section: Form                                                                                                                                                      
    # Add a text input named +n+.                                                                                                                                         
    def textinput n
      app :form, "<input type='text' placeholder='#{n.to_s}' name='#{n.to_s}'>"
    end
    ##                                                                                                                                                                    
    # :section: Form                                                                                                                                                      
    # Add a series (+r+) of radiobuttons collectively named +n+.                                                                                                          
    def radiobuttons n, *r
      r.each {|e| app :form, "<input type='radio' name='#{n.to_s}' value='#{e.to_s}'>#{e}<br>" }
    end
    def checkbox list, *c
      c.each {|ch| app :form, "#{ch.to_s} <input type='checkbox' name='#{list.to_s}[#{ch.to_s}]' value='true'><br>" }
    end
    ##                                                                                                                                                                    
    # :section: Form                                                                                                                                                      
    # Add a file upload dialogue to the form.                                                                                                                             
    def file
      app :form, "<input type='file' name='file'>"
    end
    ##                                                                                                                                                                    
    # :section: Form                                                                                                                                                      
    # Add a submit button to the form with the value +v+.                                                                                                                 
    def submit v
      app :form, "<input type='submit' value='#{v}'>"
    end
    def man
      @h = $0.gsub('muon.rb', 'doc/Object.html')
      settings.notification = File.read(@h)
    end
    ##                                                                                                                                                                    
    # :section: App                                                                                                                                                       
    # Publish +msg+ on +ch+                                                                                                                                               
    def publish ch, msg
      @r = Redis.new
      @r.publish ch, msg
    end
    ##                                                                                                                                                                    
    # :section: Form                                                                                                                                                      
    # Stream anything published to the client +id+ of the +app+.                                                                                                          
    def stream_id
      app :body, %[<pre id="x"></pre>]
      app :js, %[var es = new EventSource("/subscribe/#{@id}"); es.onmessage = function(e) { x.innerHTML += e.data };]
    end
    def stream_item i
      app :body, %[<pre id="#{i}"></pre>]
      app :js, %[var es = new EventSource("/subscribe/#{i}"); es.onmessage = function(e) { #{i}.innerHTML = e.data };]
    end
    ##                                                                                                                                                                    
    # :section: Form                                                                                                                                                      
    # Stream the values of the stream +i+.                                                                                                                                
    def stream_items i
      app :body, %[<pre id="#{i}"></pre>]
      app :js, %[var es = new EventSource("/subscribe/#{i}"); es.onmessage = function(e) { #{i}.innerHTML += e.data };]
    end
    def update_app h
      if h[:muon] != nil
        @path = h[:path]
        @css = @app[:css]
        @head = @app[:head]
        @form = @app[:form]
        @body = @app[:body]
        eval h[:muon]
        if scriptable? h[:muon]
          app :script, "#{h[:muon]}"
        end
      end
    end
    ##                                                                                                                                                                    
    # :section: App                                                                                                                                                       
    # Create session.                                                                                                                                                     
    def generate_unique_session_id!
      @i, @s = [], Redis::HashKey.new('sessions')
      6.times do
        @i << rand(10)
      end
      @_i = Digest::SHA2.hexdigest @i.join('')
      if @s[@_i] == nil
        @s[@_i] = 'X'
        return @_i
      else
        generate_unique_id!
      end
    end
    def grant_session u
      @s = Redis::HashKey.new('sessions')
      @s[@id] = u
    end
    ##                                                                                                                                                                    
    #:section: App                                                                                                                                                        
    # Revoke session +s+.                                                                                                                                                 
    def destroy_session s
      @s = Redis::HashKey.new('sessions')
      @s.delete(s)
    end
  end
  
  
  enable :sessions
  ##                                                                                                                                                                      
  #---                                                                                                                                                                    
  #:section: Muon                                                                                                                                                         
  # MUON BEFORE                                                                                                                                                           
  # 1. Generate session.                                                                                                                                                  
  # 2. Create ENV (@id, @path, @q).                                                                                                                                       
  # 3. Process app script.                                                                                                                                                
  # 4. Evaluate form goto.                                                                                                                                                
  #---                                                                                                                                                                    
  before do
    if session[:id] == nil
      session[:id] = generate_unique_session_id!
    end
    @id = session[:id]
    @path = request.path
    @q = request.query_string
    if settings.app[@path] == nil
      settings.app[@path] = {}
    end
    @app = settings.app[@path]
    @goto = nil
    eval app(:script)
    ##                                                                                                                                                                    
    # GOTO                                                                                                                                                                
    if @goto != nil; redirect @goto; end
  end
  
  
  post('/') do
    if params[:muon] != nil && settings.locked == false && params['file'] == nil;
      update_app(params);
      redirect(params[:path]);
    else;
      if params['file']
        File.open("/var/www/#{params['muon']}", 'wb') { |f| f.write params['file'][:tempfile].read }
        params['file'] = params['file'][:filename]
      end
      if $post[@path].class == Proc
        $post[@path].call(params)
      end
      if settings.post_params == true
        @ch = params['service'] || @channel || 'MUON'
        publish( @ch, JSON.generate(params));
      end
      if params['goto']
        redirect params['goto']
      else
        204;
      end
    end
  end
  #:section: Muon                                                                                                                                                         
  # MUON GET                                                                                                                                                              
  # Display the result of the +app+ script.                                                                                                                               
  #---                                                                                                                                                                    
  get('/*') do
    erb :index
  end
  ##                                                                                                                                                                      
  #---                                                                                                                                                                    
  #:section: Muon                                                                                                                                                         
  # MUON TEMPLATES                                                                                                                                                        
  #  The Muon framework generates html5 apps according to the following template.  This design provides an intuitive structure for microapplications and instills a senseof simplicity and speed into applications                                                                                                                                
  #---                                                                                                                                                                    
  #+<html>+                                                                                                                                                               
  #  +<head>+                                                                                                                                                             
  #    +<%= $std_head.join('') %>+                                                                                                                                        
  #    +<%= app :css %>+                                                                                                                                                  
  #    +<%= app :head %>+                                                                                                                                                 
  #    +<%= app :js %>+                                                                                                                                                   
  #  +</head>+                                                                                                                                                            
  #  +<body>+                                                                                                                                                             
  #    +<%= construct %>+                                                                                                                                                 
  #    +<form action='/' method='post'>+                                                                                                                                  
  #      +<input type='hidden' name='id' value='<%= @id %>'>+                                                                                                             
  #      +<%= app :form %>+                                                                                                                                               
  #    +</form>+                                                                                                                                                          
  #    +<%= app :body %>+                                                                                                                                                 
  #  +</body>+                                                                                                                                                            
  #+</html>+                                                                                                                                                              
  template(:layout) { "<html><head><%= $std_head.join('') %><%= app :css %><%= app :head %><%= app :js %></head><body><%= construct %><%= yield %></body></html>" }
  template(:index) { "<form action='/' method='post'><input type='hidden' name='id' value='<%= @id %>'><%= app :form %></form><%= app :body %>" }
  ##                                                                                                                                                                        
  #---                                                                                                                                                                      
  #:section: Muon                                                                                                                                                           
  # And if anything goes wrong, rage quit!                                                                                                                                  
  #---                                                                                                                                                                      
rescue
  exit!
end
