if Redis::Value.new("io.stick.refresh").value == nil
  Redis::Value.new("io.stick.refresh").value = 200
end

class Stick
  def initialize
    @index = 0
    @last = 0                                                              
    @move = "" 
    @menu = {
      0 => [255, 0, 0],
      1 => [0, 255, 0],
      2 => [0, 0, 255],
    }
  end
  def last
    @last
  end
  def move dir, now
    @last = now
    case 
    when dir === /N/
      n = 8
    when dir === /S/
      n = -1
    when dir === /E/
      n = @index
    when dir === /W/
      n = @index
    when dir === /X/
      n = 7
    end
    return JSON.generate(
             {
               n: n,
               r: @menu[@index][0],
               g: @menu[@index][1],
               b: @menu[@index][2],
             })
   # + JSON.generate(
   #          { 
#               n: @index,                                                 
  #             r: @menu[@index][0],                                       
  #             g: @menu[@index][1],                                       
  #             b: @menu[@index][2],                                       
  #           })
  end
end
class Stack
  def initialize
    @c = [:r, :g, :b]
    @x = 0
    @y = 0
    @z = 0
  end
  def nav d
    dx = {n: 0, r: 0, g: 0, b: 0}
    case 
    when /N/.match(d)
      dx[:n] = 7                                             
      if @y == 3
        @y = 0
      else
        @y += 1
      end
      dx[@c[@y]] = 1 
    when /S/.match(d)
      dx[:n] = 7
      if @y == 3                                                                  
        @y = 0                                                                          
      else                                                                              
        @y += 1                                                                         
      end 
      dx[@c[@y]] = 1  
    when /E/.match(d)
      dx[:n] = 5
      if @x == 3                                                                 
        @x = 0                                                                          
      else                                                                              
        @x += 1                                                                         
      end 
      dx[@c[@x]] = 1 
    when /W/.match(d)
      dx[:n] = 5
      if @x == 3                                                                  
        @x = 0                                                                          
      else                                                                              
        @x += 1                                                                         
      end                                                                         
      dx[@c[@x]] = 1 
    when /X/.match(d)
      dx[:n] = 6
      if @z == 3                                                             
        @z = 0                                                                          
      else                                                                              
        @z += 1                                                                         
      end 
      dx[@c[@z]] = 1 
    end
    return JSON.generate(dx) 
  end
end

def stick
  @stick = Stick.new
  @stack = Stack.new
@devices['stick'].write(JSON.generate({n: -1, r: 1, g: 1, b: 1})) 
Process.detach(
  fork {
    Redis.new.subscribe("io.stick") do|on|
      on.message do |c, m|
          dir = m[0..2]
          now = m[4..-1].to_i
          Redis.new.publish("t", (now - @stick.last))
          if (now - @stick.last) > Redis::Value.new("io.stick.refresh").value.to_i
            hh = @stack.nav(dir)
#            @devices['stick'].write(JSON.generate({n: 5, r: 0, g: 0, b: 0}))
#            @devices['stick'].write(JSON.generate({n: 6, r: 0, g: 0, b: 0}))
#            @devices['stick'].write(JSON.generate({n: 7, r: 0, g: 0, b: 0}))
            Redis.new.publish("io.stick.nav", hh)
#            Redis.new.publish("io.stick.stack", @stack.nav(dir))
            @devices['stick'].write(hh)
          end
      end
    end
  })
end
