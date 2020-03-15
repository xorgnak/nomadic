require 'serialport'
require 'socket'

if Redis::Value.new("battlecab").value == nil
  an = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  x = []
  8.times { x << an.split("").sample }
  Redis::Value.new("battlecab").value = x.join("")
end

ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
ip.ip_address

class Arduino
  def initialize h={}
    @h, @hits, @hit, @scan, @last = h, Hash.new { |h,k| h[k] = 0 }, Hash.new { |h,k| h[k] = 0 }, {}, {}
    ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
    port_str = @h[:dev]
    baud_rate = 115200
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    if Dir.glob(port_str).count == 1
      @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
      @sp.flush()
      sleep 5
    end
    Process.detach(
      fork {
        Redis.new.subscribe("post") do |on|
          on.message {|c, m| log(m, :pub); j = JSON.parse(m); Redis.new.publish("beacon", j['do']) }
        end
      }
    )
    Process.detach(
      fork {
        Redis.new.subscribe("beacon") do |on|
          on.message {|c, m| log(m, :beacon); write(m) }
        end
      }
    )
    ix = []
    Process.detach(
      fork {
        while true do
          i = @sp.readlines
          if i[0] != nil
#            Redis.new().publish("DEBUG.i<", "#{i}")
            if /\{.*}/.match(i[0])
              Redis.new.publish "DEBUG.input.stats", input(i[0]).stats
            elsif /.*}/.match(i[0])
              ix << i[0]
              Redis.new.publish "DEBUG.stats", input(ix.join('')).stats
              ix = []
            elsif /.*\{.*/.match(i[0])
              ix = [ i[0].gsub(/.*\{/, '{') ]
            else
              ix << i[0]
            end
          end
        end
      })
  end
  def push h={}
    Redis.new.publish("ws", JSON.generate(h))
  end
  def write c
    @sp.puts(c)
  end
  def record_zap l, r
    Redis::HashKey.new("lt:#{r}:to").incr(l)                                                                                         
    Redis::HashKey.new("lt:#{l}:out").incr(r)
  end
  def input i
#    Redis.new().publish("DEBUG.i", "#{i}")
    begin
      h = JSON.parse(i)
    rescue => e
#      Redis.new().publish("DEBUG.error", "#{e}")
      h = {}
    end
    if h.keys.length > 0
      @aura = h['local_aura']
#      Redis::SortedSet.new("lt:#{h['mac']}:#{h['direction']}").incr(h['node'])
      if h['direction'] == "out"
        @hits[h['remote_mac']] += 1
        record_zap h['local_mac'], h['remote_mac']
          push beacon: %[<p class='#{h['direction']}'>You hit #{h['remote_mac']} (#{h['remote_strength'].to_i.abs})</p>]
      elsif h['direction'] == "in"
        @hit[h['remote_mac']] += 1
        record_zap h['remote_mac'], h['local_mac']
          push beacon: %[<p class='#{h['direction']}'>#{h['remote_mac']} hit you!</p>]
      else
        if h['remoe_ap'] != "me"
          hh = Redis::HashKey.new("ap:#{h['remote_ap']}")
          @scan[h['remote_mac']] = {}
          @scan[h['remote_mac']]['ap'] = hh['ap'] = h['remote_ap']
          @scan[h['remote_mac']]['strength'] = hh['strength'] = h['remote_strength']
          Redis::HashKey.new("lt:scan").incr(h['remote_ap'])
            push beacon: %[<p class='#{h['direction']}'>#{h['remote_ap']} (#{h['remote_strength'].to_i.abs}) #{h['direction']}</p>]
        end
      end
      @last['direction'] = h['direction']
      @last['ap'] = h['remote_ap']
      @last['strength'] = h['remote_strength']
      @last['mac'] = h['remote_mac']
      #      Redis.new().publish("DEBUG.h", "#{h}")
    end
    return self
  end
  def stats
    { :aura => @aura, :last => @last, :in => @hit, :out => @hits, :scan => @scan }
  end
end
@devices = {}
def arduino d
  Arduino.new(d)
end
def devs
  Dir['/dev/ttyUSB*'].each { |e|
    d =e.gsub('/dev/ttyUSB','').to_i;
    @devices[d] = arduino(dev: e);
  }
  Redis.new.publish("DEBUG.dev", "#{@devices}")
  return @devices.keys
end

