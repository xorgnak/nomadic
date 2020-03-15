
conf = {
  city: "DEN",
}


CONF = {
  'title' => "US CENTIDEACOM DEN",
  'placeholder' => "> ",
  'welcome' => "Welcome Recruit! You've been drafted into the Inter-Dimensional Emergency Army, USA division, DEN company.  Put your phone number in below to begin your registration process.",
  'stats' => {
    'heart' => ['@', 1],
    'rocket' => ['!', 0],
    'medal' => ['#', 0]
  }
}


class Op
  def initialize h={}
    @env = h
    @ops = {}
    self.instance_eval(File.read("config.rb"))
  end
  def on(k, &b)
    @ops[k] = b
  end
  def cmds
    @ops.keys
  end
  def for i
    puts "i: #{i}"
    if /^\{/.match(i)
      j = JSON.parse(i)
      m = j[:input]
    else
      j = {}
      m = i
    end
    @ops.each_pair do |k, b|
      if k.match(m)
        b.call(j).each_pair { |k,v| j[k] = v }                                                                                                                                                                                                 
      end                                                                                                                                                                                                            
    end
    return j 
  end
end

require 'erb'
require 'sinatra'
require 'sinatra-websocket'
require 'redis-objects'

set :server, 'thin'
set :sockets, []
set :port, 8080
set :bind, '0.0.0.0'
enable :sessions

helpers do
  def msg m, h={}
    x = Op.new h
    return JSON.generate(x.for(m))
  end
  def stats
    o = []
    CONF['stats'].each_pair { |k,v| o << %[<span id="#{k}" class="stat_value">#{v[1]}</span><span class="stat_icon">#{v[0]}</span>] }
    return o.join('')
  end
  def cmds
    o = []                                                                                                                                                                                                                                                  
    Op.new.cmds.each { |e| o << %[<option value="#{e}">] }                                                                                                                           
    return o.join('')
  end
end


get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        ws.send(JSON.generate({ message: '<h3>' + CONF['welcome'] + '</h3>', content: "", state: { heart: 99, rocket: 99, medal: 99 }}))
        settings.sockets << ws
        Redis.new.subscribe("ws") do |on|
          on.subscribe do |ch, subs|
            
          end
          on.message do |ch, m|
            x = msg(m)
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
        if x != nil
          Redis.new.publish("ws", x)
        end
      end
      ws.onclose do
        warn("websocket closed")
        settings.sockets.delete(ws)
      end
    end
  end
end

__END__
@@ index
<html>
<head>
  <style>                                                                                                                                                                                                                                                   
    <%= File.read("theme.css") %>                                                                                                                                                                                                                             
  </style>                                                                                                                                                                                                                                                  
  <meta name="viewport" content="width=device-width, user-scalable=no" />                                                                                                                                                                                     
  <script                                                                                                                                                                                                                                                     
    src="https://code.jquery.com/jquery-3.4.1.min.js"                                                                                                                                                                                     
    integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="                                                                                                                                                                       
    crossorigin="anonymous"></script>
</head>
<body>
  <h1 id="head"><span id="title"><%= CONF['title'] %></span></h1>
  <h2 id="stats"><%= stats %></hr>
    <div id="msgs">
      <h3 id="message"></h3>
      <div id="content"></div>
    </div>
    <form id="foot">
      <datalist id="cmds">
	<%= cmds %>
      </datalist>
      <input type="text" id="input" list="cmds" placeholder="<%= CONF['placeholder'] %>"></input>
    </form>
</body>
<script type="text/javascript">
    window.onload = function(){
	(function(){
	    var show = function(el){
		return function(msg){ el.innerHTML = msg; }
	    }(document.getElementById('message'));
	    function update(m) {
		j = JSON.parse(m);
		console.log("update: ", j);
		$('#message').html(j.message);
		$('#content').html(j.content);
		    <% CONF['stats'].each_pair do |k,v| %>
		    $('#<%= k %>').text(j.state.<%= k %>);
		    <% end %>
	    }
	    var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);
	    ws.onopen    = function()  { show("<h3>connecting...</h3>"); };
	    ws.onclose   = function()  { show('<h3>ERR 0x0101dead</h3><p>Reload to continue...</p>'); }
	    ws.onmessage = function(m) { update(m.data); };
	    
	    var sender = function(f){
		var input     = document.getElementById('input');
		input.onclick = function(){ input.value = "" };
		f.onsubmit    = function(){
		    ws.send(input.value);
		    input.value = '';
		    return false;
		}
	    }(document.getElementById('foot'));
	})();
    }
</script>
</html>
