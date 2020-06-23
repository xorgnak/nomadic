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
  Redis.new.publish("DEBUG.sp", "#{@sp}")
    ix = []
    Process.detach(
      fork {
        while true do
          while (i = @sp.gets) do       # see note 2
            Redis.new.publish("io.stick", i) 
#            if /\n/.match(i)
#              ix << i
#              if /^... .+\r\n$/.match(ix.join(""))
#                Redis.new.publish("io.stick", ix.join(""))
#              end
#              ix = []
#            else
#              ix << i
#            end
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
  def stats
    { :aura => @aura, :last => @last, :in => @hit, :out => @hits, :scan => @scan }
  end
end
@devices = {}
def arduino d
  Arduino.new(d)
end
def devs
  @devices['stick'] = arduino(dev: '/dev/ttyACM0');
end
Redis.new.publish("DEBUG.dev", "#{@devices}") 

