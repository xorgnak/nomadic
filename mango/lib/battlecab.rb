require 'serialport'

if Redis::Value.new("battlecab").value == nil
  an = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  x = []
  8.times { x << an.split("").sample }
  Redis::Value.new("battlecab").value = x.join("")
end
  
class Arduino
  def initialize h={}
    @h = h
    port_str = @h[:dev]
    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    if Dir.glob(port_str).count == 1
      @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits,
                           parity)
      @sp.flush()
      update_dev
    end
    ix = []
    Process.detach(
      fork {
        while i = @sp.readlines do
          if i[0] != nil
#            Redis.new.publish( "battlecab.0", "#{i[0]}")
            if /aaa:/.match(ix.join('')) && /:xxx\r\n/.match(ix.join(""))
              inc = /aaa:(.*):xxx\r\n/.match(ix.join(''))
              Redis.new.publish( "battlecab.1", "#{inc}")
              if inc != nil
                input inc[1]
              ix = []
            end
            else
              ix << i[0].force_encoding(Encoding::ASCII_8BIT)
            end
          end
          @sp.flush()
        end
      })
  end
  def input i
    Redis.new.publish( "battlecab.2", "#{i}")
    ks = [:mode, :lvl, :team, :data]
    h = i.split(" ")
    if h[0]
    u0 = ks.zip(h[0].split(":"))
    if h[1]
      if hu = /000:(.*):fff/.match(h[1])
        u1 = ks.zip(hu[1].split(":"))
      else
        u1 = nil
      end
    else
      u1 = nil
    end
    end
    hh = { 0 => u0, 1 => u1 }
#    Redis.new.publish( "battlecab.3", "#{u0} #{u1}")
  end
  def output o
    @sp.write(o)
    @sp.flush()
    Redis.new.publish("battlecab.out", o)
  end
  def update_dev h={}
    if h[:team]
      t = h[:team]
    else
      t = CONF['battlecab']['team']
    end
    if h[:lvl]
      l = h[:lvl]
    else
      l = CONF['battlecab']['lvl']
    end
    output("#{Redis::Value.new('battlecab').value} #{t} #{l}")
  end
end
class Player
  def initialize u
    @u = u
    @h = Redis::HashKey.new("bc:user:#{u}")
  end
  def attrs
    @h
  end
  def team t
    Redis::HashKey.new('teams')[@u] = t
  end
end
def player p
  Player.new(p)
end
@devices = {}
def arduino d
  Arduino.new(d)
end
Dir['/dev/ttyACM*'].each { |e|
  d =e.gsub('/dev/ttyACM','').to_i;
  @devices[d] = arduino(dev: e);
}
