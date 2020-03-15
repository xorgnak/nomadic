require 'sinatra/base'

class PryWeb < Sinatra::Base
  EXAMPLE = {
    'panel' => %[panel(item);],
    'puts' => %[puts(item);],
    'print' => %[print(item);],
    'date' => %[date(name);],
    'time' => %[time(name)],
    'select' => %[select(name, mode, options);],
    'text' => %[text(name);],
    'color' => %[color(name, callback);],
    'button' => %[button(name, callback, *values)]
  }
  HELP = [
    %[<h3>Relax, we'll get through this together!</h3>],
    %[<details><summary>About</summary>],
    %[<details><summary>Ruby</summary>],
    %[<p>Ruby is a high level, interpreted, object oriented language with a simple and intuitive syntax.</p>],
    %[</details>],
    %[<details><summary>This tool</summary>],                                                                                                                                                                                                             
    %[<p>This tool wraps the ruby programming language in a web-socket based interface.  It also provides helpful methods to simplify common frontend tasks.  The rest is plain ol ruby.</p>],
    %[</details>],
    %[</details>],
    %[<details><summary>Basics</summary>],                                                                                                                                                                                                              
    %[<details><summary>button</summary>],                                                                                                                                                                                                                      
    %[<p>Add a button and define what to do when it's clicked.</p>],
    %[<code>#button(name, callback, *values);<br>button(:btn, %[console.log("button clicked." $(this))], "click me");<br>button(:fg, change('#head', :bg), :red, :yellow, :blue);</code>],
    %[</details>],                                                                                                                                                                                                                                              
    %[<details><summary>panel</summary>],                                                                                                                                                                                                                   
    %[<p>Add an item to the top panel.</p>],
    %[<code>#panel(item);<br>panel("Hello, World");<br>panel(Time.now);<br>panel(button(:youtube, %[console.log("youtube button", $(this))], :one, :two, :three));</code>],
    %[</details>],
    %[<details><summary>puts</summary>],                                                                                                                                                                                                                        
    %[<p>Add an item to the output and add a new line.</p>],         
    %[<code>#puts(item);<br>puts("Hello, World");<br>puts(Time.now);<br>puts(@env);</code>],                                                                                      
    %[</details>],
    %[<details><summary>print</summary>],                                                                                                                                                                                                                     
    %[<p>Add an item to the output.</p>],                                                                                                                                                                                                                     
    %[<code>#print(item);<br>print("Hello, World");<br>print(Time.now);</code>],                                                                                      
    %[</details>],
    %[<details><summary>date</summary>],                                                                                                                                                                         
    %[<p>Add a date selection widget.</p>],                                                                                                                                                                                                                     
    %[<code>#date(name);<br>date(:appointment);</code>],                                                                                      
    %[</details>],
    %[<details><summary>time</summary>],                                                                                                                                                                                      
    %[<p>Add a time selection widget.</p>],                                                                                                                                                                                                                     
    %[<code>#time(name);<br>time(:appointment);</code>],                                                                                      
    %[</details>],
    %[<details><summary>select</summary>],                                                                                                                                                                                                               
    %[<p>Add a selection widget.</p>],                                                                                                                                                                                                                     
    %[<code>#select(name, mode, options);<br>select(:color, :single, {"Red" => "red", "Yellow" => "yellow", "Blue" => "blue"});</code>],                                                                                                                        
    %[</details>],
    %[<details><summary>text</summary>],                                                                                                                                                                                                                
    %[<p>Add a text input.</p>],                                                                                                                                                                                                                     
    %[<code>#text(name);<br>text(:name);</code>],                                                                                                                                                                                                        
    %[</details>],
    %[<details><summary>color</summary>],                                                                                              
    %[<p>Add a color selection widget.</p>],                                                                                                                  
    %[<code>#color(name, callback);<br>color(:fg, change('#panel', :fg));</code>],                                                                                     
    %[</details>],
    %[</details>],
    %[<details><summary>Callbacks</summary>],
    %[<details><summary>change</summary>],
    %[<p>Change css property to the value of the item given to the object calling it.</p>],
    %[<code>#change(item, property);<br>change('#head', :bg)</code>],
    %[</details>],
    %[<details><summary>set</summary>],                                                                                                                                                                                                                      
    %[<p>Set the value of the item given to the value of the object calling it.</p>],                                                                                                                                                                     
    %[<code>#change(item, text);<br>set('#panel', "Hello, World!");</code>],
    %[</details>],
    %[</details>]
  ].join('')
  INDEX = [
    %[<html><head>],
    %[<meta name="viewport" content="width=device-width, user-scalable=no" /> ],
    %[<script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>],
    %[<link rel="stylesheet" href="/codemirror/lib/codemirror.css"><script src="/codemirror/lib/codemirror.js"></script>],
    %[<script src="/codemirror/addon/edit/matchbrackets.js"></script>],
    %[<script src="/codemirror/ruby.js"></script>],
    %[</head><body><form id="form" name="form" method="post" action="/">],
    %[<style>],
    %[.blink { animation: blink-animation 1s steps(5, start) infinite;-webkit-animation: blink-animation 1s steps(5, start) infinite;}@keyframes blink-animation {to {visibility: hidden;}}@-webkit-keyframes blink-animation {to {visibility: hidden;}}],
    %[body { height: 100%; width: 100%; margin: 0; background-color: black; color: white; }],
    %[#head { width: 100%; margin: 0; padding: 2%; background-color: black; color: white; }],
    %[#input {width: 100%; height: 100%; display: none; }],
    %[#btns {  }],
    %[#output { background-color: white; color: black; }],
    %[</style>],
    %[<h3 id="head"><button id="edit" type="button">+</button><button id="run" class="btn" type="submit" name="do" value="run">=</button><span id="panel"></span><span id="btns"></span></h3>],
    %[<textarea name="input" id="input"># your ruby goes here. :-)</textarea><div id="output"></div>],
    %[</form>],
    %[<script>],
    %[var input = document.getElementById('input');],
    %[var editor = CodeMirror.fromTextArea(input, { lineNumbers: true });],
    %[window.onload = function() {(function(){],
    %[$("#edit").on('click', function(e){ $(".CodeMirror").toggle(); });],
    %[var show = function(el){],
    %[return function(msg){ el.innerHTML += msg; }],
    %[}(document.getElementById('panel'));],
    %[function update(m) {],
    %[j = JSON.parse(m);],
    %[if (j != null) {],
    %[console.log("update: ", j);],
    %[console.log("log", j.log);],
    %[$('#panel').html(j.panel);],
    %[$('#input').val(j.input);],
    %[$('#beacon').html(j.beacon);],
    %[$('#output').html(j.output);],
    %[eval(j.js);],
    %[}}],                                                         
    %[var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);],
    %[ws.onopen    = function()  { show('<span class="init">prypi v1.0 - ruby on tv :-)</span>'); };],
    %[ws.onclose   = function()  { show('<span class="warn">Reload Page...</span>'); };],
    %[ws.onmessage = function(m) { update(m.data); };],
    %[var sender = function(f){],
    %[f.onsubmit    = function(ev){],
    %[ev.preventDefault();],
    %[ws.send(JSON.stringify($('#form').serializeArray().reduce(function(m,o){ m[o.name] = o.value; return m;}, {})));],
    %[input.value = '';],
    %[$(".CodeMirror").css('display', 'none');],
    %[return false; ],
    %[} }(document.getElementById('form'));})();}],
    %[</script></body></html>]
  ].join('')
  class Op
    def initialize i
      log "i: #{i}", :op
      @env, @cmds, @panel, @js, @style = {}, {}, [], [], Hash.new {|h,k| h[k] = {}}
      @i, @o = i, []
      begin
      if i.class == String
        @o << instance_eval(@i)
      else
        @i = i.delete('input')
        @env = i
        @i.split(';').each { |e| x = instance_eval(e); if x != nil; @o << x; end }
      end
      rescue => e
        @o << "<code>#{CGI.escapeHTML(e.message)}</code>"
      else
        log "o: #{@o}", :op
      end
      return @o 
    end
    def help
      @o << HELP
      return nil
    end
    def panel i
      @panel << i
      return nil
    end
    def head
      o = []
      @panel.each {|e| o << %[<span class="widget">#{e}</span>] }
      return o.join('')
    end
    def input
      "#{@i}"
    end
    def output
      "#{@o.join('')}"
    end
    def puts i
       return "#{i}<br>"
    end
    def game
      @o << %[<h3 id="beacon"></h3>]
      panel(button(:game, %[jQuery.post("/", { "do": $(this).val() }, function(e) { console.log("btn", e) })], :scan, :zap, :vibe))
    end
    def print i
      return i
    end
    def js
      o = []
      @style.each_pair {|k,v| v.each_pair { |kk,vv| o << %[$("#{k}").css("#{kk}", "#{vv}");] }}
      @js.each { |e| o << e }
      return o.join('')
    end
    def javascript *j
      j.each {|e| @js << e }
    end
    def style o, k, v
      @style[o][k] = v
    end
    def node id, h={}                                                                                                                                                                                                                                           
      if h[:class]                                                                                                                                                                                                                                              
        c = h[:class]                                                                                                                                                                                                                                           
      end                                                                                                                                                                                                                                                       
      return %[<#{h[:tag]} id="#{id}" class="node #{c}" >#{h[:text]}<#{h[:tag]}>]                                                                                                                                                                              
    end
    def p i
      %[<p>#{i}</p>]
    end
    def h3 i
      %[<h1>#{i}</h3>]
    end
    def link h={}
      %[<a class="btn #{h[:class]}" href="#{h[:uri]}">#{h[:text]}</a>]
    end
    def input_element n, h={}
      o = []; h.each_pair { |k,v| o << %[#{k}="#{v}"] }
      return %[<input placeholder="#{n}" name="#{n}" value="#{@env[n]}" #{o.join(' ')}>]                                                                                                                                                                        
    end
    def change i, w
      if w == :bg
        %[$('#{i}').css('background-color', $(this).val())]
      elsif w == :fg
        %[$('#{i}').css('color', $(this).val())]
      elsif w == :bd
        %[$('#{i}').css('border-color', $(this).val())]
      end
    end
    def set i, v
      if v == :this
        vv = %[$(this).val()]
      else
        vv = v
      end
      %[$('#{i}').text(#{vv})]
    end
    def post k, v
      %[$]
    end
    def example *k
      ix = @i.split('\n')
      if k[0]
        ix << EXAMPLE[k[0]]
      else
        ix << EXAMPLE.values.join("\n")
      end
      @i = ix.join("\n")
      return nil
    end
    def color(n, c, h={})
      h[:type] = 'color'
      h[:id] = n
      h[:name] = n
      log @env[n], :color
      if @env.has_key?(n.to_s)
        h[:value] = @env[n.to_s]
      end
      @js << %[$('##{n}').on('change', function() { #{c}; });]
      input_element(n, h)
    end
    def date(n, h={})
      h[:type] = 'date'
      input_element(n, h)
    end
    def time(n, h={})
      h[:type] = 'time'
      input_element(n, h)
    end
    def text(n, h={})
      h[:type] = 'text'
      input_element(n, h)
    end
    def button_element n, h={}
      o = []; h.each_pair { |k,v| o << %[#{k}="#{v}"] }
      return  %[<button type="button" name="do" #{o.join(' ')}>#{n}</button>]                                                                                                                                    
    end
    def button *i
      n = i.shift
      c = i.shift
      @js << %[$('.#{n}').on('click', function() { #{c}; });] 
      i.each { |e| @o << button_element(e, class: n, value: e) }
      return nil
    end
    def select n, *m, h
      o = []
      h.each_pair {|k,v| o << %[<option value="#{v}">#{k}</option>] }
      if m[0] == :open
        i = %[<datalist id="#{n}">#{o.join('')}</datalist><input type="text" list="#{n}" name="#{n}" placeholder="#{n}">]
      elsif m[0] == :multi
        i  = %[<select name="#{n}" multi=multi>#{o.join('')}</select>]
      else
        i = %[<select name="#{n}">#{o.join('')}</select>]
      end
    end
  end
  def initialize
    super
    
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

  end
  post '/' do
    content_type "application/json"
    log "#{params}", :post
    x = Op.new(params)                                                                        
    if x != nil
      h = { js: x.js, panel: x.head, input: x.input, output: ERB.new(x.output).result(binding) }
      j = JSON.generate(h)
      #log ["h: #{h}", "j: #{j}"], :post
      settings.sockets.each { |e| e.send(j) }                                                                                   
    end
    return { beacon: j['beacon'] }
  end
  get '/youtube' do
    return CONF["youtube"]
  end
  get '/' do                                                
    #log ["REQ: #{request}", "PAR: #{params}"], :notice
    if !request.websocket?
      #log ["REQ: /"], :notice 
      erb INDEX, layout: false
    else
      #log ["REQ: ws:", "PAR: #{params}"], :notice 
      request.websocket do |ws|                                                                  
        ws.onopen do
          #log "[WS] OPEN", :notice
          settings.sockets << ws
              Redis.new.subscribe("ws") { |on|
                on.message {|ch, m|
                  settings.sockets.each { |e|
                    #log("PS:ws: #{m}", :put);
                    e.send(m)
                  }
                }
              }
        end
        ws.onmessage do |m|
          Redis.new.publish "post", m
          #log "m: #{m}", :ws
          j = JSON.parse(m)
          j.each_pair {|k,v| @env[:"#{k}"] = v; log v, k }
          x = Op.new(j)
          #log ["m: #{m}", "x: #{x}"], :msgws
          if x != nil
            h = { js: x.js, panel: x.head, input: x.input, output: ERB.new(x.output).result(binding) }
            #log "h: #{h}", :ws
            settings.sockets.each { |e| e.send(JSON.generate(h)) }
          end
        end
        ws.onclose do
          #log "[WS] closed", :notice
          Process.kill(10, @wsproc)
          Process.wait
          settings.sockets.delete(ws)
        end
      end
    end
  end 
end

def pryweb
  Process.detach(fork { PryWeb.run! })
end


